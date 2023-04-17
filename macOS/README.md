# `macOS` configuration guide

## `homebrew`

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## `iTerm2`

```bash
brew install --cask iterm2
```

After installing `iTerm2`, follow the in

## Create sandboxed Applications directory
```bash
cd ~
mkdir Applications
```

## `Brave`
```bash
brew install --cask brave-browser
```


## `docker` using `homebrew`
Manually install from Internet: [Link to install docker](https://docs.docker.com/desktop/install/mac-install/)

## `Dropbox`
Manually install from Internet: [Dropbox installation link](https://www.dropbox.com/install)

## Install `Google Chrome`
Manually install from Internet: [Google Chrome Installation](https://www.google.com/chrome/?brand=CHBD&gclid=Cj0KCQiAtrnuBRDXARIsABiN-7DwYfMptQpT89IC7YMyGO3KJjG9af1QhGZJfHlPn6n8TOdKQ7h9nkoaAlbPEALw_wcB&gclsrc=aw.ds)

## `Intellij Ultimate`
```bash
brew install --cask intellij-idea
```

## `Jolt of Caffeine`
Mac App Store manual installation

## `karabiner-elements`
```bash
brew install --cask karabiner-elements
```
### Configuration
![alt text](https://raw.githubusercontent.com/gnvalente92/configure-new-machine/master/macOS/resources/karabinerconfig.png)

## `Microsoft Office`
Manually install from Internet: [Microsoft Office installation link](https://www.office.com/)

## `NordVPN`
Mac App Store manual installation

## `PyCharm CE`
```bash
brew install --cask pycharm-ce
```

## Install `python` the correct way
[`Python installation link`](https://opensource.com/article/19/6/virtual-environments-python-macos)

## Instal `Rambox`
```bash
brew install --cask rambox
```

## `Scala` (`sbt`)  (with `jdk`)
```sh
brew tap AdoptOpenJDK/openjdk
brew install --cask adoptopenjdk8
brew install sbt
```

## `Spectacle`
Manually install from Internet: [Spectacle installation link](https://www.spectacleapp.com/)

## `Spotify`
```bash
brew install --cask spotify
```

## `Vagrant`
Install virtualbox directly from the [`website`](https://www.virtualbox.org/wiki/Downloads) (intel and arm architectures supported) and then proceed installing using `homebrew`:
```bash
brew install --cask vagrant
brew install --cask vagrant-manager
```

## `Visual Studio Code`
```bash
brew install --cask visual-studio-code
```
