# ----------------
# Make help script
# ----------------

# Usage:
# Add help text after target name starting with '\#\#'
# A category can be added with @category. Team defaults:
# 	dev-environment
# 	docker
# 	test

# Output colors
GREEN  := $(shell tput -Txterm setaf 2)
WHITE  := $(shell tput -Txterm setaf 7)
YELLOW := $(shell tput -Txterm setaf 3)
RESET  := $(shell tput -Txterm sgr0)

# Script
HELP_FUN = \
	%help; \
	while(<>) { push @{$$help{$$2 // 'options'}}, [$$1, $$3] if /^([a-zA-Z\-]+)\s*:.*\#\#(?:@([a-zA-Z\-]+))?\s(.*)$$/ }; \
	print "usage: make [target]\n\n"; \
	for (sort keys %help) { \
	print "${WHITE}$$_:${RESET}\n"; \
	for (@{$$help{$$_}}) { \
	$$sep = " " x (32 - length $$_->[0]); \
	print "  ${YELLOW}$$_->[0]${RESET}$$sep${GREEN}$$_->[1]${RESET}\n"; \
	}; \
	print "\n"; }

help:
	@perl -e '$(HELP_FUN)' $(MAKEFILE_LIST)

composer-install: ##@composer Runs composer install in the web folder
	composer install -vvv

import-db: ##@local site building Runs MySQL commands and imports seed DB
	lando db-import db_dump/snh.sql.gz

new-site: ##@local site building Runs composer install and imports seed db
	lando composer-install
	lando import-db
	lando cim
	lando drush updb -y
	lando drush entup -y
	lando cron
	lando cr

cim: ##@drupal Runs lando drush cim -y
	lando drush cim -y

cex: ##@drupal Runs lando drush cex -y
	lando drush cex -y

cr: ##@drupal Runs lando drush cr -y
	lando drush cr -y

cron: ##@drupal Runs lando drush cron -y
	lando drush cron -y

provision: ##@drupal Runs site provisioning steps
	make composer-install
	lando cim
	lando drush updb -y
	lando drush entup -y
	lando cron
	lando cr

