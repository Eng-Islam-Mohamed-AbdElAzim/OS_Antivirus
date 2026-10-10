.PHONY: prepare antivirus restore

prepare:
	mkdir -p test_dir malicious_dir

antivirus: prepare
	chmod +x antivirusd.sh
	./antivirusd.sh test_dir malicious_dir

restore: prepare
	chmod +x restore.sh
	./restore.sh test_dir malicious_dir