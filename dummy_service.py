import time
import os

def main():
        print(f"Dummy Service Started. PID: {os.getpid()}")
        print("I will run forever until you kill me")

        try:
                while True:
                        time.sleep(10)
        except KeyboardInterrupt:
                print("Service stoppin..")

if __name__ == "__main__":
        main()
