@echo off
:run_loop
python GUI.py

if exist "run.txt" (
	echo starting Easy-Wav2Lip...
	python run.py
	goto run_loop
	)
