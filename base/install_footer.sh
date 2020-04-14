
if [ ! -e "$HOME/.profile" ]; then
  cp "$PWD/sample_profile" "$HOME/.profile"
else
  echo "You already have a .profile."
  echo "You can set up your paths by sourcing $PWD/env.sh"
  echo "See $PWD/sample_profile for a snippet that does this"
fi
