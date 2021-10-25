from pathlib import Path
from os import getcwd, makedirs, chdir, environ
from shutil import copytree, copyfile, rmtree
from distutils.dir_util import copy_tree
import git
import subprocess

import sys
sys.path.append("build_packages") # yuck...
from helpers import timestamp, bcolors


def pi_gen_build(
        package_dir=Path("build_packages/output/"),
        output_image_dir=Path(""),
        image_filename="sensorgnome.img",
        clean=True, # True: produce clean build, false: attempt to restart/continue
):
    repo = "https://github.com/RPi-Distro/pi-gen.git"
    commit = "225f69828fa05361d6028edf2d7a69db73fe2b45"
    base_dir = getcwd()

    temp_dir = base_dir / Path("pi-gen-temp")
    if clean:
        rmtree(temp_dir, ignore_errors=True)
        makedirs(temp_dir)
        subprocess.run(["docker", "rm", "-v", "pigen_work"])

    build_dir = temp_dir / Path("pi-gen")
    if build_dir.exists():
        print(f"[{timestamp()}]: {repo} already cloned.")
    else:
        print(f"[{timestamp()}]: Git clone from {repo}, commit: {commit[:8]}.")
        git.Git(temp_dir).clone(repo)
        subprocess.run(f"cd {build_dir}; pwd; git status", shell=True)
        git.Git(build_dir).checkout(commit)

    print(f"[{timestamp()}]: Copying debian packages from `build_packages'.")
    sg_stage = build_dir / Path("stageSG")
    install_packages = sg_stage / Path("00-packages/")
    _ = copytree(base_dir / package_dir, install_packages, dirs_exist_ok=True)

    print(f"[{timestamp()}]: Copying other build files.")
    build_files = base_dir / Path("build_raspbian/build_files/")
    copyfile(build_files / Path("Dockerfile"), build_dir / Path("Dockerfile"))
    copyfile(build_files / Path("config"), build_dir / Path("config"))
    _ = copytree(build_files / Path("stageSG/"), sg_stage, dirs_exist_ok=True)

    print(f"[{timestamp()}]: Changing default mirrors.")
    _ = copy_tree(str(build_files / Path("stage0/")), str(build_dir / Path("stage0")))

    print(f"[{timestamp()}]: Overwriting partition creation.")
    _ = copy_tree(str(build_files / Path("export-image/")), str(build_dir / Path("export-image")))

    print(f"[{timestamp()}]: Generating Raspbian image. This may take a while.")

    env = environ.copy()
    if not clean:
        env["CONTINUE"] = "1"
    env["PRESERVE_CONTAINER"] = "1" # keeps the container, even if successful, so can chg & re-run
    cmd = [f"./build-docker.sh"]
    try:
        subprocess.run(cmd, env=env, cwd=build_dir, check=True)
    except subprocess.CalledProcessError as e:
        print(f"[{timestamp()}]: {bcolors.RED}Pi-gen build failed.{bcolors.ENDC}")
        print(e)
        return False

    deploy_path = build_dir / "deploy"
    deploy_image_name = list(deploy_path.glob('*.img'))[0]
    output_path = base_dir / output_image_dir / image_filename
    copyfile(deploy_path / deploy_image_name, output_path)
    print(f"[{timestamp()}]: {bcolors.GREEN}Pi-gen build finished successfully.{bcolors.ENDC}")
    return output_path


if __name__ == "__main__":
    base_dir = Path(getcwd())
    temp_dir = base_dir / Path("pi-gen-temp")
    # Start from a clean slate, remove any existing build dirs.
    rmtree(temp_dir, ignore_errors=True)
    makedirs(temp_dir)
    image_name = "sg-test.img"
    pi_gen_build(temp_dir, Path("../"), image_name)
