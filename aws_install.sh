#!/bin/bash
# by markodj

export AWS_WORKDIR=$HOME/Downloads/aws
export AWS_VER=$(aws --version | awk -F"[/ ]+" '/aws-cli/{print $2}')

spinner()
{
    local pid=$!
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

delete_files()
{
    sudo rm -rf /usr/local/aws-cli
    sudo rm -rf /usr/local/bin/aws
    sudo rm -rf /usr/local/bin/aws_completer
    sudo rm -rf $AWS_WORKDIR/aws/
}

install_aws()
{
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" --create-dirs -o "$AWS_WORKDIR/awscliv2.zip"
    unzip $AWS_WORKDIR/awscliv2.zip -d $AWS_WORKDIR > /dev/null
    sudo $AWS_WORKDIR/aws/install 2> /dev/null
}

echo ""
echo "----------------------------------------"
echo "  Welcome to AWS CLI Installation script"
echo "----------------------------------------"
echo ""
cat << EOF
  
           ▄▄▄       █     █░  ██████     ▄████▄   ██▓     ██▓
          ▒████▄    ▓█░ █ ░█░▒██    ▒    ▒██▀ ▀█  ▓██▒    ▓██▒
          ▒██  ▀█▄  ▒█░ █ ░█ ░ ▓██▄      ▒▓█    ▄ ▒██░    ▒██▒
          ░██▄▄▄▄██ ░█░ █ ░█   ▒   ██▒   ▒▓▓▄ ▄██▒▒██░    ░██░
           ▓█   ▓██▒░░██▒██▓ ▒██████▒▒   ▒ ▓███▀ ░░██████▒░██░
           ▒▒   ▓▒█░░ ▓░▒ ▒  ▒ ▒▓▒ ▒ ░   ░ ░▒ ▒  ░░ ▒░▓  ░░▓  
            ▒   ▒▒ ░  ▒ ░ ░  ░ ░▒  ░ ░     ░  ▒   ░ ░ ▒  ░ ▒ ░
            ░   ▒     ░   ░  ░  ░  ░     ░          ░ ░    ▒ ░
                ░  ░    ░          ░     ░ ░          ░  ░ ░  
                                       ░                    
EOF

echo ""
echo "Checking for AWS CLI on system..."
echo ""

sleep 2 & spinner

if [[ -n $(which aws) ]];
then
  echo " --------------------------"
  echo " AWS CLI already installed."
  echo " Current version - $AWS_VER"
  echo " --------------------------"  
  echo ""
  echo " Would You like to remove AWS-CLI or check for updates?"
  echo " [U]pdate [R]emove [C]ancel"
  read answer
  case $answer in
    
    u | U | Update | UPDATE | update)
      sudo $AWS_WORKDIR/aws/install --update & spinner
      echo " ---------------------------"
      echo " AWS CLI already up to date."
      echo " Have fun!"
      echo " ---------------------------"
      exit
      ;;
      
    r | R | remove | Remove | REMOVE)
      delete_files & spinner
      sleep 1
      echo " ---------------"
      echo " AWS CLI removed"
      echo " ---------------"
      echo "    C ya l8r"
      exit
      ;;
    
    *)
      echo " Ok, c ya!"
      exit
      ;;
  esac
else
  echo " No AWS CLI found..."
  echo " Continue with installation?"
  echo " [Y]es [N]o"
  read yn
  case $yn in
     
    y | Y | Yes | yes | YES)
      echo ""
      echo " Here we go!"
      echo ""
      sleep 1
      ;;
    
    n | N | No | NO | no)
      echo ""
      echo " Ok, bye..."
      echo ""
      exit
      ;;
  esac    
fi

echo " ----------------"
echo " Updating system"
echo " ----------------"

sudo apt update || echo " Update failed"

echo " -----------------------------------------------------------------"
echo " Checking for and installing required packages (curl and unzip)..."
echo " -----------------------------------------------------------------"
sleep 2 & spinner

REQUIRED_PKG="curl"
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
if [ "" = "$PKG_OK" ]; 
then
  echo " ---------------------------------------"
  echo " No $REQUIRED_PKG found. Setting up $REQUIRED_PKG."
  sudo apt-get -y install $REQUIRED_PKG
else
  echo "$REQUIRED_PKG already installed!"
fi

REQUIRED_PKG="unzip"
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
if [ "" = "$PKG_OK" ]; 
then
  echo " ------------------------" 
  echo " No $REQUIRED_PKG found. Setting up $REQUIRED_PKG."
  sudo apt-get -y install $REQUIRED_PKG
else
  echo " $REQUIRED_PKG already installed!"
  echo " ------------------------"
fi 

echo ""
echo " ---------------------"
echo "  Packages are ready"
echo " Installing AWS CLI v2"
echo " ---------------------"
echo ""

install_aws & spinner

echo ""
echo " ================================================"
echo " AWS CLI version $(aws --version | awk -F"[/ ]+" '/aws-cli/{print $2}') is succesfully installed!"
echo ""
echo " Don't forget tom run 'aws configure' command"
echo " to configure your AWS account and connection!"
echo ""
echo " Have fun!"
echo " ================================================"
echo ""
