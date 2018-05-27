######################################################
#### WARNING PIPING TO BASH IS STUPID: DO NOT USE THIS
######################################################

# TESTED ON UBUNTU 18.04 LTS

# TO DO
# - git custom file
# - install vscode
# - consolidate the apt install junk...

# SETUP & RUN
# sudo apt -y install curl
# curl -sL https://raw.githubusercontent.com/jimangel/ubuntu-tweaks/master/script.sh | sudo -E bash -

# set vars
goVersion="1.10.2"
kubectlVersion="1.10.2"

# set font colors
red='\033[0;31m'
nocolor='\033[0m' 

# build function to see if program exists
cant_find_program() {
  if command -v "${1}" > /dev/null 2>&1; then
    return 1
  fi
}

# install tlp for better power mgmt on laptop
if cant_find_program tlp; then
  sudo apt -y install tlp tlp-rdw --no-install-recommends
fi

# create git folder in homedir
mkdir ~/Git 2>/dev/null

# install sublime
# to remove: sudo apt remove sublime-text && sudo apt autoremove
if cant_find_program subl; then
  wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add - &> /dev/null
  echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list > /dev/null
  sudo apt update
  sudo apt -y install sublime-text
fi

# fix vi
printf ":set nocompatible\n:set backspace=2" > ~/.vimrc

# put dock at bottom
if ! gsettings list-recursively | grep dock-position | grep BOTTOM > /dev/null; then
  gsettings set org.gnome.shell.extensions.dash-to-dock dock-position BOTTOM
fi

# git placeholder
# sudo apt -y install git
# git config --global user.email "<email>"
# git config --global user.name "<name>"

# install media codecs and fonts
if ! grep "Commandline: apt install ubuntu-restricted-extras" /var/log/apt/history.log; then
sudo apt -y install ubuntu-restricted-extras
fi

# reminder to update to AM/PM format
echo "MANUALLY UPDATE TO A 12HR CLOCK"
echo "STEPS: Click on Activities and search for 'Settings' and launch it. Click on Details at the bottom of the sidebar and then select 'Date & Time'."

echo "IF YOU WANT TO UPDATE RUN: # update and upgrade all
sudo apt update && sudo apt upgrade"

# install terminator terminal
if cant_find_program terminator; then
sudo apt -y install terminator
fi

# install golang
# note: to upgrade 'sudo rm -rf /usr/local/go' and change version in script
if cant_find_program go; then
wget https://dl.google.com/go/go${goVersion}.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go${goVersion}.linux-amd64.tar.gz
rm -rf go${goVersion}.linux-amd64.tar.gz
cat << 'EOT' >> ~/.bashrc

# set PATH so it includes go bin if it exists
if [ -d "/usr/local/go/bin" ] ; then
    PATH="$PATH:/usr/local/go/bin"
fi
EOT
# create working dirs
mkdir -p ~/go/{bin,src,pkg} 2>/dev/null
printf "${red}!!! MUST RESTART TERMINAL BEFORE GO CAN BE USED${nc}\n"
fi

# install kubectl binary
if cant_find_program kubectl; then
wget https://storage.googleapis.com/kubernetes-release/release/v${kubectlVersion}/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
fi

if ! grep "source <(kubectl completion bash)" ~/.bashrc > /dev/null; then
cat << 'EOT' >> ~/.bashrc

# enable kubectl auto completion
echo "source <(kubectl completion bash)"
EOT
fi

# install virtual box
if cant_find_program VBoxManage; then
  if grep --color vmx /proc/cpuinfo > /dev/null; then
    sudo apt -y install virtualbox
  else
    echo "VT-x or AMD-v virtualization must be enabled in your computer’s BIOS and re-run this script"
  fi
fi

# install mini-kube
# https://github.com/kubernetes/minikube/blob/v0.27.0/README.md
if cant_find_program minikube; then
  curl -Lo minikube https://storage.googleapis.com/minikube/releases/v0.27.0/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/
fi