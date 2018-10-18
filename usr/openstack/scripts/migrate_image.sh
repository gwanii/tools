#!/bin/bash
exclude_images="centos-7.2"
glance_dir="/var/lib/glance/images"
remote=192.168.9.2

for image in $(glance image-list|grep -vE "$exclude_images"|awk '{print $2"#"$4}'|grep "-"|grep -v ID); do
  id=$(echo "$image"|cut -d# -f1)
  name=$(echo "$image"|cut -d# -f2)
  echo "- Copy image: $name to ${remote}..."
  rsync -v "$glance_dir"/"$id" "$remote":"$glance_dir"/"$name"
  echo "- Upload image: $name to glance..."
  ssh "$remote" "source ~/.bashrc; glance image-create --name $name --disk-format qcow2 --container-format bare --visibility public --property hw_watchdog_action=pause --progress < $glance_dir/$name; rm $glance_dir/$name"
  echo "---"
done
