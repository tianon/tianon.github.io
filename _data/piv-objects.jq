# jq --tab --null-input --from-file piv-objects.jq | tee piv-objects.json

[
	# https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-73-4.pdf#page=38
	[ "9A", "X.509 Certificate for PIV Authentication", "0x0101", "5FC105", 1905 ],
	[ "9E", "X.509 Certificate for Card Authentication", "0x0500", "5FC101", 1905 ],
	[ "9C", "X.509 Certificate for Digital Signature", "0x0100", "5FC10A", 1905 ],
	[ "9D", "X.509 Certificate for Key Management", "0x0102", "5FC10B", 1905 ],
	# $ for i in {1..20}; do printf "[ \"%02X", "Retired X.509 Certificate for Key Management %d\", \"0x10%02X\", \"5FC1%02X\", 1905 ],\n" "$i" "$(( 0x82 + i - 1 ))" "$i" "$(( 0x0D + i - 1 ))"; done
	# (this could be pure jq, but number to hex in jq is more annoying than it frankly should be)
	[ "82", "Retired X.509 Certificate for Key Management 1", "0x1001", "5FC10D", 1905 ],
	[ "83", "Retired X.509 Certificate for Key Management 2", "0x1002", "5FC10E", 1905 ],
	[ "84", "Retired X.509 Certificate for Key Management 3", "0x1003", "5FC10F", 1905 ],
	[ "85", "Retired X.509 Certificate for Key Management 4", "0x1004", "5FC110", 1905 ],
	[ "86", "Retired X.509 Certificate for Key Management 5", "0x1005", "5FC111", 1905 ],
	[ "87", "Retired X.509 Certificate for Key Management 6", "0x1006", "5FC112", 1905 ],
	[ "88", "Retired X.509 Certificate for Key Management 7", "0x1007", "5FC113", 1905 ],
	[ "89", "Retired X.509 Certificate for Key Management 8", "0x1008", "5FC114", 1905 ],
	[ "8A", "Retired X.509 Certificate for Key Management 9", "0x1009", "5FC115", 1905 ],
	[ "8B", "Retired X.509 Certificate for Key Management 10", "0x100A", "5FC116", 1905 ],
	[ "8C", "Retired X.509 Certificate for Key Management 11", "0x100B", "5FC117", 1905 ],
	[ "8D", "Retired X.509 Certificate for Key Management 12", "0x100C", "5FC118", 1905 ],
	[ "8E", "Retired X.509 Certificate for Key Management 13", "0x100D", "5FC119", 1905 ],
	[ "8F", "Retired X.509 Certificate for Key Management 14", "0x100E", "5FC11A", 1905 ],
	[ "90", "Retired X.509 Certificate for Key Management 15", "0x100F", "5FC11B", 1905 ],
	[ "91", "Retired X.509 Certificate for Key Management 16", "0x1010", "5FC11C", 1905 ],
	[ "92", "Retired X.509 Certificate for Key Management 17", "0x1011", "5FC11D", 1905 ],
	[ "93", "Retired X.509 Certificate for Key Management 18", "0x1012", "5FC11E", 1905 ],
	[ "94", "Retired X.509 Certificate for Key Management 19", "0x1013", "5FC11F", 1905 ],
	[ "95", "Retired X.509 Certificate for Key Management 20", "0x1014", "5FC120", 1905 ],
	empty
	| {
		slot: .[0],
		description: .[1],
		containerID: .[2],
		tag: .[3],
		minBytes: .[4],
	}
]
