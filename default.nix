with (import <nixpkgs> {});

stdenv.mkDerivation {
	name = "STM32";
	version = "0.0.1";

	buildInputs = [
		gcc-arm-embedded
        clang-tools
		cmake
		gnumake
		stm32flash
		stm32cubemx
		libusb1
		stlink
	];
}
