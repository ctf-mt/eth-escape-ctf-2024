start-challenge-server:
	cd server && docker compose up --build

start-dist-challenge-server:
	cd distfiles && docker compose up --build

start-challenge-server-dev:
	cd server && docker compose -f compose.development.yaml up --build

run-solver:
	cd solver && docker build . -t run-solver
	docker run -it -e CHALLENGE_HOST=localhost -e CHALLENGE_PORT=31337 --network=host run-solver python3 solve.py

run-solver-remote:
	cd solver && docker build . -t run-solver
	docker run -it -e CHALLENGE_HOST=localhost -e CHALLENGE_PORT=31337 --network=host run-solver python3 solve.py

PY_FILES = server/src/eth_sandbox/*.py server/src/deploy/*.py solver/*.py

generate-distfiles:
	rm -rf distfiles
	cp -r server distfiles
	rm distfiles/compose.yaml
	mv distfiles/compose.development.yaml distfiles/compose.yaml
	sed -i 's/FLAG=flag{[^}]*}/FLAG=flag{redacted}/g' distfiles/compose.yaml
	sed -i 's/SHARED_SECRET=.*/SHARED_SECRET=redactedredacted/g' distfiles/compose.yaml
	tar -czf distfiles.tar.gz distfiles

sync:
	cp solver/src/challenge/* server/src/contracts/

test-solver:
	cd solver && forge init --force --no-commit && forge test --match-contract ExploitTest -vvv --ffi
