container_name="`cat container_name.txt`"

sudo docker exec -it ${container_name} /bin/bash
