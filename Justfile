set dotenv-load := false

staged := ".build/zirconium"
stable_profiles := "base,base-desktop,bootc-ostree,brew,zirconium-bootc-ostree,x9"
camera_profiles := stable_profiles + ",x9-camera-experimental"
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
    cd {{ staged }} && sudo mkosi -B -ff --debug --profile={{ stable_profiles }}

build-camera: prepare
    cd {{ staged }} && sudo mkosi -B -ff --debug --profile={{ camera_profiles }}

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
