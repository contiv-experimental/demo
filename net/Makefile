.PHONY: test

vendor-bats:
	cd ..
	git subtree add -P vendor/bats  https://github.com/sstephenson/bats.git master -m "vendor in the bats scripts for testing" --squash

test:
	../vendor/bats/bin/bats ./test/aci_installer.bats
