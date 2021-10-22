# Nice to have a client for testing
sudo apt install postgresql-client -y

sudo mkdir -p /opt/postgresql
sudo cp /tmp/boundary-postgresql.crt /opt/postgresql/boundary-postgresql.crt
sudo cp /tmp/boundary-postgresql.key /opt/postgresql/boundary-postgresql.key
sudo chown -R 999:999 /opt/postgresql
sudo chmod -R 600 /opt/postgresql

docker stop postgres-boundary || true && docker rm postgres-boundary || true
docker run --name postgres-boundary -e POSTGRES_DB=boundary -e POSTGRES_PASSWORD=boundary -e POSTGRES_USER=boundary \
 -v "/opt/postgresql/boundary-postgresql.crt:/var/lib/postgresql/boundary-postgresql.crt:ro" \
 -v "/opt/postgresql/boundary-postgresql.key:/var/lib/postgresql/boundary-postgresql.key:ro" \
 --user 999:999 -p 5432:5432 -d postgres -c ssl=on -c ssl_cert_file=/var/lib/postgresql/boundary-postgresql.crt -c ssl_key_file=/var/lib/postgresql/boundary-postgresql.key

# Give postgres some time to start
sleep 15

#until psql postgresql://boundary:boundary@localhost:5432/boundary -c '\l'; do
#  echo >&2 "$(date +%Y%m%dt%H%M%S) Postgres is unavailable - sleeping"
#  sleep 1
#done
#echo >&2 "$(date +%Y%m%dt%H%M%S) Postgres is up - executing command"
