docker run -it --rm \
--net="host" \
--volume ""$(pwd)"/../documentation:/home:rw" \
--workdir="/home" \
--name="sphinx" \
sphinx