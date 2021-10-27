import os
import sys
import json
import argparse
import subprocess
from pathlib import Path
from build_packages.helpers import timestamp, bcolors, image_name
from build_raspbian.build_raspbian import pi_gen_build

try:
    import git # not used here, but import to produce a useful message if missing
except ModuleNotFoundError as e:
    print(f"Cannot import module git: {e}\nYou probably need to pip install GitPython")
    sys.exit(1)

"""
The purpose of this script is the overall runner to buil packages to be installed on a sensorgnome,
    to generate a system image and to put them and any other supporting files together for a complete sensorgnome image.
"""

def docker_build_image(dockerfile_location, dockcross_image, clean=False):
    """
    Build the docker image used to build packages.
    Args:
        dockerfile_location (Path): Path to the dockerfile to run.
        dockcross_image (str): Name of the dockcross image to use.
    Returns:
        Path object containing the dockcross executable script.
    """

    dockcross_exec_path = dockerfile_location / dockcross_image

    # Start by building the dockcross Docker image, start by checking whether we already have it
    cmd = ["docker", "images", "--format", "{{json .}},"]
    if clean:
        got_dockcross = False
    else:
        try:
            images = subprocess.run(cmd, capture_output=True, check=True)
        except CalledProcessError as e:
            print(f"[{timestamp()}]: {bcolors.RED}Listing docker images failed:\n{e}{bcolors.ENDC}")
            return False
        images = json.loads(b"[" + images.stdout + b"{}]")
        got_dockcross = any([
            i.get("Repository","") == dockcross_image and i.get("Tag","") == "latest"
            for i in images
        ])
    if got_dockcross:
        print(f"[{timestamp()}]: Dock-cross image already exists, nothing to do")
    else:
        print(f"[{timestamp()}]: Building dock-cross image: {dockcross_image}")
        build = subprocess.Popen(["docker", "build", "-t", dockcross_image, dockerfile_location])
        exit_code = build.wait()
        if exit_code != 0:
            print(f"[{timestamp()}]: {bcolors.RED}Docker build failed.{bcolors.ENDC}")
            return False
        dockcross_exec_path.unlink(missing_ok=True)

    # Build dockcross executable, which uses the image to perform cross-compilation
    if not clean and dockcross_exec_path.exists():
        print(f"[{timestamp()}]: Dockcross executable already exists, nothing to do")
    else:
        print(f"[{timestamp()}]: Creating dock-cross executable at: {dockcross_exec_path}")
        try:
            result = subprocess.run(["docker", "run", f"{dockcross_image}"], stdout=subprocess.PIPE)
            with open(dockcross_exec_path, 'wb') as f:
                f.write(result.stdout)
        except subprocess.CalledProcessError:
            print(f"[{timestamp()}]: {bcolors.RED}Docker run failed.{bcolors.ENDC}")
        # make it executable
        dockcross_exec_path.chmod(0o755)
    return True

def docker_build_packages(dockcross_exec, clean=True):
    """
    Use a created docker container to cross-compile and build the .deb packages.
    Runs build_packages/build_packages.py with (for now) hard-coded commands.
    Args:
        dockcross_exec (Path): Path to the dockcross executable script to use for cross-compiling.
    Returns:
        bool: True if the command completed successfully, False if it didn't.
    """
    #cmd = [f"./{dockcross_exec} bash -c 'cd build_packages && sudo python3 build_packages.py -t build-temp -o output -c $CC -p $CXX  -x armv7-unknown-linux-gnueabi'"]
    #print(f"command: {cmd}")
    #build = subprocess.Popen(cmd, shell=True)
    if not clean:
        print("Sorry, build_packages does not yet support incremental (non-clean) builds")
    subdir = "build_packages"
    parent = Path("..").resolve()
    cmd = [
        "../" + str(dockcross_exec),
        "-a", f"-v {parent}:/mnt", # mount parent onto /mnt to allow access to other repos
        "python3", "build_packages.py",
        "-t", "build-temp",
        "-o", "output",
        "-c", "armv7-unknown-linux-gnueabi-gcc",
        "-p", "armv7-unknown-linux-gnueabi-g++",
        "-s", "armv7-unknown-linux-gnueabi-strip",
        "-x", "armv7-unknown-linux-gnueabi"
    ]
    print(f"command run in {subdir}: {' '.join(cmd)}")
    build = subprocess.Popen(cmd, cwd=subdir)
    exit_code = build.wait()
    if exit_code != 0:
        print(f"[{timestamp()}]: {bcolors.RED}Docker build failed.{bcolors.ENDC}")
        return False
    return True


def create_image(final_image_name, clean=True):
    print(f"[{timestamp()}]: Starting build of Raspbian image.")
    result = pi_gen_build(image_filename=final_image_name, clean=clean)
    return result


def parse_command_line():
    parser = argparse.ArgumentParser(
        add_help=True,
        description="Create a dockcross cross-compilation image, use that to build the sensorgnome "
            "packages, and assemble it all into an SD-card image.",
        epilog="If -d, -p, or -i is specified only that step is performed.")
    parser.add_argument('-d', '--docker', dest="do_docker", action='store_true',
        help="Build sensorgnome dockcross image.")
    parser.add_argument('-p', '--packages', dest="do_packages", action='store_true',
        help="Build sensorgnome packages.")
    parser.add_argument('-i', '--image', dest="do_image", action='store_true',
        help="Build rPi image.")
    parser.add_argument('-c', '--clean', dest="clean", action='store_true',
        help="Perform the build step(s) from a clean slate.")
    args = parser.parse_args()
    return args


if __name__ == "__main__":
    options = parse_command_line()
    options.do_all = not(options.do_docker or options.do_packages or options.do_image)

    # Step 1: build a dockcross image from a base dockcross image
    dockerfile_location = Path("docker/")
    dockcross_image = "sensorgnome-armv7-rpi-buster"
    dockcross_exec = dockerfile_location / dockcross_image
    if options.do_all or options.do_docker:
        if not docker_build_image(dockerfile_location, dockcross_image, options.clean):
            sys.exit(1)
    
    # Step 2: build sensorgnome packages
    if options.do_all or options.do_packages:
        if not docker_build_packages(dockcross_exec, options.clean):
            sys.exit(1)
    
    # Step 3: build rPi image
    if options.do_all or options.do_image:
        final_image_name = image_name()
        img = create_image(final_image_name, clean=options.clean)
        if img:
            print(f"[{timestamp()}]: {bcolors.GREEN}Sensorgnome image {final_image_name} built successfully!{bcolors.ENDC}")
            print(f"[{timestamp()}]: Output image is at {img}")
        else:
            print(f"[{timestamp()}]: {bcolors.RED}Sensorgnome build failed.{bcolors.ENDC}")
            print("To restart, run python -c 'import build; build.create_image(build.image_name(), clean=False)'")
