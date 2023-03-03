.PHONY: FORCE
all: FORCE
	$(MAKE) -C .. paydacoin_qt test_paydacoin_qt
clean: FORCE
	$(MAKE) -C .. paydacoin_qt_clean test_paydacoin_qt_clean
check: FORCE
	$(MAKE) -C .. test_paydacoin_qt_check
paydacoin-qt paydacoin-qt.exe: FORCE
	 $(MAKE) -C .. paydacoin_qt
apk: FORCE
	$(MAKE) -C .. paydacoin_qt_apk
