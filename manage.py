import configparser
import json
import logging
import subprocess

logging.basicConfig(format='[%(levelname)s]\t: %(message)s', level=logging.DEBUG)

config_path = "./config.ini"


def main():
    config = configparser.ConfigParser()
    config.read(config_path)
    logging.info("Read in config file.")
    for section in config.sections():
        tags = json.loads(config.get(section, "tag"))
        imgs = json.loads(config.get(section, "name"))
        url, path = config[section]["url"], config[section]["path"]
        for tag, img in zip(tags, imgs):
            logging.info(f"Pull image from docker://{url}:{tag} into {path}/{img}.sif.")
            pull_cmd = f"singularity pull --force {path}/{img}.sif docker://{url}:{tag}"
            subprocess.call(pull_cmd, shell=True)

if __name__ == "__main__":
    main()
