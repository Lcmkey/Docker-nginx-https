up:
	docker-compose up -d

down:
	docker-compose down

build:
	docker-compose -p test build

rmi:
	docker rmi -f dockernginxhttps_nginx-custom

img:
	docker 
	
create-conf:
	docker cp nginx-custom:/etc/nginx .
	mv nginx conf
	$(MAKE) down
	mkdir -p ./conf/certs
	cat default.conf >> conf/conf.d/default.conf


F_EXISTS=$(shell [ -e ./test.json ] && echo 1 || echo 0 )
ifeq ($(F_EXISTS), 0)
	TEST := $(shell curl -s https://ipvigilante.com/$(curl -s https://ipinfo.io/ip) >> test.json)
endif


ifndef C
# C := $(shell cat test.json | jq '.data.country_name')
C := HK
endif

ifndef ST
ST := $(shell cat test.json | jq '.data.city_name' | sed 's/"//g')
# ST := HK
endif

ifndef L
L := $(shell cat test.json | jq '.data.city_name' | sed 's/"//g')
# L := HK
endif

ifndef O
O := $(shell cat test.json | jq '.data.city_name' | sed 's/"//g')
# O := Central District
endif

ifndef OU
OU := IT Department
# OU := HK
endif

ifndef CN
CN := 127.0.0.2
endif

ifndef EA
EA := your-email@domain.com
endif


# [ -f ./test.json ] && echo exists || echo not exists
# $(shell curl -s https://ipvigilante.com/$(curl -s https://ipinfo.io/ip) >> test.json)
# echo $(shell cat test.json | jq '.data.country_name')
# $(shell curl -s https://ipvigilante.com/112.120.227.27) >> test.json)
# sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout example.key -out example.crt
# -subj "/C=HK/ST=HK/L=HK/O=Global Security/OU=IT Department/CN=127.0.0.2/emailAddress=your-email@domain.com"
# -subj "/C=$(C)/ST=$(ST)/L=$(L)/O=$(O)/OU=$(OU)/CN=$(CN)/emailAddress=$(EA)"
# sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -subj "/C=HK/ST=HK/L=HK/O=Global Security/OU=IT Department/CN=127.0.0.2/emailAddress=your-email@domain.com" -keyout example.key -out example.crt
create-certs:
	sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -subj "/C=$(C)/ST=$(ST)/L=$(L)/O=$(O)/OU=$(OU)/CN=$(CN)/emailAddress=$(EA)" -keyout example.key -out example.crt
	mv example.crt example.key ./conf/certs
	@[ -f ./test.json ] && rm test.json || true
	
	