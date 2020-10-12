#!/usr/bin/env python3

import argparse
import configparser
import json
import logging
import os
import copy
import shutil
import subprocess

logging.basicConfig(format='[%(levelname)s]\t: %(message)s',
                    level=logging.DEBUG)

software_name = [path for path in os.listdir() if os.path.isdir(path)]
software_name.remove('.git')

enable_options = ["enable", "disable", "default"]


def deploy(config_path, name, tag, force):
    config = configparser.ConfigParser()
    config.read(config_path)
    logging.info("Read in config file.")
    module_path = config["common"]["module_path"]
    software_list = copy.deepcopy(config.sections())
    software_list.remove("common")
    os.makedirs(module_path, exist_ok=True)
    for section in software_list:
        tags = json.loads(config.get(section, "tag"))
        imgs = json.loads(config.get(section, "name"))
        enables = json.loads(config.get(section, "enable"))
        url, path = config[section]["url"], os.path.join(module_path, config[section]["path"])
        os.makedirs(path, exist_ok=True)
        if name != None and name != config[section]["path"]:
            continue
        if tag != None and tag not in imgs:
            logging.error(f"  Tag not available. {tag} not in {imgs}")
            exit(-1)
        logging.info(f"Process [{section}].")
        for pull_tag, img_name, enable in zip(tags, imgs, enables):
            if enable not in enable_options:
                logging.error(f"  Option enable {tag} not in {enable_options}")
                exit(-1)
            if (tag != None and tag != img_name) or enable == "disable":
                continue
            src_lua = os.path.join(config[section]["path"], img_name+".lua")
            dst_lua = os.path.join(path, img_name+".lua")
            shutil.copyfile(src_lua, dst_lua)
            logging.info(f"  Copy {src_lua} to {dst_lua}.")
            if (not force) and os.path.exists(f"{path}/{img_name}.sif"):
                logging.info(
                    f"  {path}/{img_name}.sif exsit. You can use `--force` to do a force update."
                )
            else:
                logging.info(
                    f"  Pull image from docker://{url}:{pull_tag} into {path}/{img_name}.sif."
                )
                pull_cmd = f"singularity pull --force {path}/{img_name}.sif docker://{url}:{pull_tag}"
                subprocess.call(pull_cmd, shell=True)

            if enable == "default":
                logging.info(f"  Make {img_name} as default module.")
                default_path = os.path.join(path, "default")
                if os.path.islink(default_path):
                    os.unlink(default_path)
                os.symlink(dst_lua, default_path)


def main():
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest='subparser')

    parser_deploy = subparsers.add_parser('deploy')
    parser_deploy.add_argument('-c',
                               '--config',
                               dest='config_path',
                               default='./config.ini')
    parser_deploy.add_argument('-n',
                               '--name',
                               dest='name',
                               choices=software_name)
    parser_deploy.add_argument('-t', '--tag', dest='tag')
    parser_deploy.add_argument('-f',
                               '--force',
                               dest='force',
                               action='store_true')

    kwargs = vars(parser.parse_args())
    if not kwargs['subparser']:
        parser.print_help()
        exit(-1)
    globals()[kwargs.pop('subparser')](**kwargs)


if __name__ == "__main__":
    main()
