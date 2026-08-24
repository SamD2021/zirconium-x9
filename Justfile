set dotenv-load := false

staged := ".build/zirconium"
base_profiles := "base,base-desktop,brew,zirconium-bootc-ostree"

# X9 post-install hooks must relocate /opt payloads before bootc removes /opt.

stable_profiles := base_profiles + ",x9-camera-experimental,x9,bootc-ostree"
camera_profiles := base_profiles + ",x9,x9-camera-experimental,bootc-ostree"
image := env("IMAGE_FULL", "localhost/zirconium-x9:latest")

default:
    @just --list

prepare:
    ./scripts/prepare

cat-config: prepare
    cd {{ staged }} && mkosi cat-config --debug --profile={{ stable_profiles }}

cat-config-camera: prepare
    cd {{ staged }} && mkosi cat-config --debug --profile={{ camera_profiles }}

build: prepare
    cd {{ staged }} && env GITHUB_TOKEN="${GITHUB_TOKEN:-}" sudo --preserve-env=GITHUB_TOKEN mkosi -B -ff --debug --environment=GITHUB_TOKEN --profile={{ stable_profiles }}

build-camera: prepare
    cd {{ staged }} && env GITHUB_TOKEN="${GITHUB_TOKEN:-}" sudo --preserve-env=GITHUB_TOKEN mkosi -B -ff --debug --environment=GITHUB_TOKEN --profile={{ camera_profiles }}

load:
    env IMAGE_FULL={{ image }} just --justfile {{ staged }}/Justfile --working-directory {{ staged }} load

rechunk:
    env IMAGE_FULL={{ image }} just --justfile {{ staged }}/Justfile --working-directory {{ staged }} rechunk

lint:
    env IMAGE_FULL={{ image }} just --justfile {{ staged }}/Justfile --working-directory {{ staged }} lint

inspect:
    ./scripts/assert-image {{ image }}

clean:
    ./scripts/clean
