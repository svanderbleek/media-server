apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 575159689BEFB442
echo 'deb http://download.fpcomplete.com/ubuntu trusty main' | sudo tee /etc/apt/sources.list.d/fpco.list
apt-get update -y
apt-get install stack -y
apt-get install libncurses5-dev -y
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
apt-get install -y nodejs
npm install -g elm
stack setup
stack build
cp media-server.conf /etc/init/
service media-server start
