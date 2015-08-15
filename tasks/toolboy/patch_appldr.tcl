#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#

# Priority: 0003
# Description: PATCH: APPLDR - Miscellaneous

# Option --patch-misc-rogero-patches: [3.xx/4.xx]  -->  Patch Appldr with misc ROGERO patches
# Option --patch-appldr-fself-330: [3.xx]  -->  Patch Appldr to allow Fself (3.10-3.30) set debug true (Experimental!)
# Option --patch-appldr-fself-340: [3.xx]  -->  Patch Appldr to allow Fself (3.40) set debug true (Experimental!)
# Option --patch-appldr-fself-355: [3.xx]  -->  Patch Appldr to allow Fself (3.55) set debug true (Experimental!)
# Option --add-356keys-to-appldr341: [3.xx]  -->  Patch Appldr to add the 3.56 keys to appldr 3.41
# Option --add-360keys-to-appldr355: [3.xx]  -->  Patch Appldr to add the 3.60 keys to appldr 3.55

# Type --patch-misc-rogero-patches: boolean
# Type --patch-appldr-330: boolean
# Type --patch-appldr-340: boolean
# Type --patch-appldr-355: boolean
# Type --add-356keys-to-appldr341 boolean
# Type --add-360keys-to-appldr355 boolean

namespace eval ::patch_appldr {

    array set ::patch_appldr::options {
		--patch-misc-rogero-patches true
        --patch-appldr-fself-330 false
        --patch-appldr-fself-340 false
        --patch-appldr-fself-355 false
		--add-356keys-to-appldr341 false
        --add-360keys-to-appldr355 false 
    }

    proc main { } {	
	
        # call the function to do any APPLDR selected patches	
		if {${::NEWMFW_VER} < "3.60"} { set self "appldr" } else { set self "appldr.self" }		
		set path $::CUSTOM_COSUNPKG_DIR
		set file [file join $path $self]		
		::modify_coreos_file $file ::patch_appldr::Do_AppLdr_Patches	        
    }
	
	##################			 proc for applying any  "MISCELLANEOUS"  appldr patches    	##############################################################
	#
	#

    proc Do_AppLdr_Patches {self} {
        log "Patching [file tail $self]"
		::modify_self_file $self ::patch_appldr::AppLdr_elf_Patches
    }
	proc AppLdr_elf_Patches {elf} {
		
		log "Applying MISC APPLDR patches...."	
		
		# patch appldr for "misc" ROGERO patches
		if {$::patch_appldr::options(--patch-misc-rogero-patches)} {			
			# verified OFW ver. 3.60 - 4.55+
			# OFW 3.55 == 0x (0x)
			# OFW 3.60 == 0x1BE8 (0x146E8)
			# OFW 3.70 == 0x1BE8 (0x146E8)  
			# OFW 4.00 == 0x1C90 (0x14790)  
			# OFW 4.46 == 0x1CE0 (0x147E0)
			# OFW 4.55 == 0x1CE0 (0x147E0)
			log "Patching Appldr with Rogero patch 1/3"						 
			set search  "\x34\x09\x80\x80\x04\x00\x2A\x03\x18\x04\x80\x81\x34\xFF\xC0\xD0"
			set replace "\x40\x80\x00\x03"
			set offset 4 
			set mask 0			
			# PATCH THE ELF BINARY
            catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"      
			
			log "Patching Appldr with Rogero patch 2/3"	
			# verified OFW ver. 3.60 - 4.55+
			# OFW 3.60 == 0x1EB0 (0x149B0)
			# OFW 3.70 == 0x1EB0 (0x149B0)  
			# OFW 4.00 == 0x1F58 (0x14A58)  
			# OFW 4.46 == 0x1FA8 (0x14AA8)
			# OFW 4.55 == 0x1FA8 (0x14AA8)
			# **** NOT IN OFW 3.55 ****
			if {${::NEWMFW_VER} > "3.56"} { 
				set search  "\x55\xC0\x09\x91\x58\x24\x88\x90\x23\x00\x0A\x10\x1C\x08\x00\x84\x40\x80\x04\x05\x43\xF0\x00\x03"
				set mask	"\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x00\x00\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF"
				set replace "\x40\x80\x00\x10"
				set offset 4  						
				# PATCH THE ELF BINARY
				catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"
			} else {	
				log "SKIPPING Appldr-->Rogero patch 2/3....(not found in OFW < 3.60)"				
			}
			
			log "Patching Appldr with Rogero patch 3/3"	
			# verified OFW ver. 3.60 - 4.55+
			# OFW 3.60 == 0x3D1C (0x1681C)
			# OFW 3.70 == 0x3D1C (0x1681C)  
			# OFW 4.00 == 0x3DD4 (0x168D4)  
			# OFW 4.46 == 0x3DA4 (0x168A4)
			# OFW 4.55 == 0x3DA4 (0x168A4)
			# **** NOT IN OFW 3.55 ****
			if {${::NEWMFW_VER} > "3.56"} {
				set search  "\x04\x00\x01\xD0\x21\x00\x0F\x03\x04\x00\x28\x83\x33\x7C\x46\x80\x04\x00\x01\xD0"
				set mask	"\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x00\x00\x00\xFF\xFF\xFF\xFF"
				set replace "\x40\x80\x00\x03"
				set offset 12 						
				# PATCH THE ELF BINARY
				catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"		
			} else {	
				log "SKIPPING Appldr-->Rogero patch 3/3....(not found in OFW < 3.60)"				
			}
		}		
		# patch appldr for "fself 3.30"
		if {$::patch_appldr::options(--patch-appldr-fself-330)} {
		
			log "Patching Appldr to allow Fself (3.10-3.30)"							  
			set search  "\x40\x80\x0e\x0d\x20\x00\x69\x09\x32\x00\x04\x80\x32\x80\x80"
			set replace "\x40\x80\x0e\x0c\x20\x00\x57\x83\x32\x11\x73\x00\x32\x80\x80"
			set offset 7  
			set mask 0				
			# PATCH THE ELF BINARY
            catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"      
		}
		# patch appldr for "fself 3.40"
		if {$::patch_appldr::options(--patch-appldr-fself-340)} {
		
			log "Patching Appldr to allow Fself (3.40)"						 
			set search  "\x40\x80\x0e\x0c\x20\x00\x57\x83\x32\x00\x04\x80\x32\x80\x80"
			set replace "\x40\x80\x0e\x0c\x20\x00\x57\x83\x32\x10\xF8\x80\x32\x80\x80"
			set offset 7 
			set mask 0				
			# PATCH THE ELF BINARY
            catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"      
		}
		# patch appldr for "fself 3.55"
		if {$::patch_appldr::options(--patch-appldr-fself-355)} {
		
			log "Patching Appldr to allow Fself (3.55)"						 
			set search  "\x40\x80\x0e\x0c\x20\x00\x57\x83\x32\x00\x04\x80\x32\x80\x80"
			set replace "\x40\x80\x0e\x0c\x20\x00\x57\x83\x32\x11\x73\x00\x32\x80\x80"
			set offset 7 
			set mask 0				
			# PATCH THE ELF BINARY
            catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"      
		}
		# patch appldr to add "3.56 keys" to "appldr 3.41"
		if {$::patch_appldr::options(--add-356keys-to-appldr341)} {
		
			log "Patching Application loader 3.41 to add 3.56 keys"
			log "patching revision check"								
			set search    "\x5D\x01\x83\x14"
			set replace   "\x5D\x03\x83\x14"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
            catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"      							
			
			log "patching 2nd keypair addr"
			set search    "\x43\x5D\x28\x06"
			set replace   "\x43\x5b\xD8\x06"
			set offset 0	
			set mask 0				
			# PATCH THE ELF BINARY
            catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"      		
			
			# patch in "356" key data
			set search     "\x00\x00\x00\x00\x00\x95\xF5\x00\x19\xE7\xA6\x8E\x34\x1F\xA7\x2E"
			set replace    "\x95\xF5\x00\x19\xE7\xA6\x8E\x34\x1F\xA7\x2E\xFD\xF4\xD6\x0E\xD3"
			append replace "\x76\xE2\x5C\xF4\x6B\xB4\x8D\xFD\xD1\xF0\x80\x25\x9D\xC9\x3F\x04"
			append replace "\x4A\x09\x55\xD9\x46\xDB\x70\xD6\x91\xA6\x40\xBB\x7F\xAE\xCC\x4C"
			append replace "\x6F\x8D\xF8\xEB\xD0\xA1\xD1\xDB\x08\xB3\x0D\xD3\xA9\x51\xE3\xF1"
			append replace "\xF2\x7E\x34\x03\x0B\x42\xC7\x29\xC5\x55\x55\x23\x2D\x61\xB8\x34"
			append replace "\xB8\xBD\xFF\xB0\x7E\x54\xB3\x43\x00\x00\x00\x21\x00\x00\x00\x00"
			append replace "\x79\x48\x18\x39\xC4\x06\xA6\x32\xBD\xB4\xAC\x09\x3D\x73\xD9\x9A"
			append replace "\xE1\x58\x7F\x24\xCE\x7E\x69\x19\x2C\x1C\xD0\x01\x02\x74\xA8\xAB"
			append replace "\x6F\x0F\x25\xE1\xC8\xC4\xB7\xAE\x70\xDF\x96\x8B\x04\x52\x1D\xDA"
			append replace "\x94\xD1\xB7\x37\x8B\xAF\xF5\xDF\xED\x26\x92\x40\xA7\xA3\x64\xED"
			append replace "\x68\x44\x67\x41\x62\x2E\x50\xBC\x60\x79\xB6\xE6\x06\xA2\xF8\xE0"
			append replace "\xA4\xC5\x6E\x5C\xFF\x83\x65\x26\x00\x00\x00\x11\x00\x00\x00\x00"
			append replace "\x4F\x89\xBE\x98\xDD\xD4\x3C\xAD\x34\x3F\x5B\xA6\xB1\xA1\x33\xB0"
			append replace "\xA9\x71\x56\x6F\x77\x04\x84\xAA\xC2\x0B\x5D\xD1\xDC\x9F\xA0\x6A"
			append replace "\x90\xC1\x27\xA9\xB4\x3B\xA9\xD8\xE8\x9F\xE6\x52\x9E\x25\x20\x6F"
			append replace "\x8C\xA6\x90\x5F\x46\x14\x8D\x7D\x8D\x84\xD2\xAF\xCE\xAE\x61\xB4"
			append replace "\x1E\x67\x50\xFC\x22\xEA\x43\x5D\xFA\x61\xFC\xE6\xF4\xF8\x60\xEE"
			append replace "\x4F\x54\xD9\x19\x6C\xA5\x29\x0E\x00\x00\x00\x13\x00\x00\x00\x00"
			append replace "\xC1\xE6\xA3\x51\xFC\xED\x6A\x06\x36\xBF\xCB\x68\x01\xA0\x94\x2D"
			append replace "\xB7\xC2\x8B\xDF\xC5\xE0\xA0\x53\xA3\xF5\x2F\x52\xFC\xE9\x75\x4E"
			append replace "\xE0\x90\x81\x63\xF4\x57\x57\x64\x40\x46\x6A\xCA\xA4\x43\xAE\x7C"
			append replace "\x50\x02\x2D\x5D\x37\xC9\x79\x05\xF8\x98\xE7\x8E\x7A\xA1\x4A\x0B"
			append replace "\x5C\xAA\xD5\xCE\x81\x90\xAE\x56\x29\xA1\x0D\x6F\x0C\xF4\x17\x35"
			append replace "\x97\xB3\x7A\x95\xA7\x54\x5C\x92\x00\x00\x00\x0B\x00\x00\x00\x00"
			append replace "\x83\x8F\x58\x60\xCF\x97\xCD\xAD\x75\xB3\x99\xCA\x44\xF4\xC2\x14"
			append replace "\xCD\xF9\x51\xAC\x79\x52\x98\xD7\x1D\xF3\xC3\xB7\xE9\x3A\xAE\xDA"
			append replace "\x7F\xDB\xB2\xE9\x24\xD1\x82\xBB\x0D\x69\x84\x4A\xDC\x4E\xCA\x5B"
			append replace "\x1F\x14\x0E\x8E\xF8\x87\xDA\xB5\x2F\x07\x9A\x06\xE6\x91\x5A\x64"
			append replace "\x60\xB7\x5C\xD2\x56\x83\x4A\x43\xFA\x7A\xF9\x0C\x23\x06\x7A\xF4"
			append replace "\x12\xED\xAF\xE2\xC1\x77\x8D\x69\x00\x00\x00\x14\x00\x00\x00\x00"
			append replace "\xC1\x09\xAB\x56\x59\x3D\xE5\xBE\x8B\xA1\x90\x57\x8E\x7D\x81\x09"
			append replace "\x34\x6E\x86\xA1\x10\x88\xB4\x2C\x72\x7E\x2B\x79\x3F\xD6\x4B\xDC"
			append replace "\x15\xD3\xF1\x91\x29\x5C\x94\xB0\x9B\x71\xEB\xDE\x08\x8A\x18\x7A"
			append replace "\xB6\xBB\x0A\x84\xC6\x49\xA9\x0D\x97\xEB\xA5\x5B\x55\x53\x66\xF5"
			append replace "\x23\x81\xBB\x38\xA8\x4C\x8B\xB7\x1D\xA5\xA5\xA0\x94\x90\x43\xC6"
			append replace "\xDB\x24\x90\x29\xA4\x31\x56\xF7\x00\x00\x00\x15\x00\x00\x00\x00"
			append replace "\x6D\xFD\x7A\xFB\x47\x0D\x2B\x2C\x95\x5A\xB2\x22\x64\xB1\xFF\x3C"
			append replace "\x67\xF1\x80\x98\x3B\x26\xC0\x16\x15\xDE\x9F\x2E\xCC\xBE\x7F\x41"
			append replace "\x24\xBD\x1C\x19\xD2\xA8\x28\x6B\x8A\xCE\x39\xE4\xA3\x78\x01\xC2"
			append replace "\x71\xF4\x6A\xC3\x3F\xF8\x9D\xF5\x89\xA1\x00\xA7\xFB\x64\xCE\xAC"
			append replace "\x24\x4C\x9A\x0C\xBB\xC1\xFD\xCE\x80\xFB\x4B\xF8\xA0\xD2\xE6\x62"
			append replace "\x93\x30\x9C\xB8\xEE\x8C\xFA\x95\x00\x00\x00\x2C\x00\x00\x00\x00"
			append replace "\x94\x5B\x99\xC0\xE6\x9C\xAF\x05\x58\xC5\x88\xB9\x5F\xF4\x1B\x23"
			append replace "\x26\x60\xEC\xB0\x17\x74\x1F\x32\x18\xC1\x2F\x9D\xFD\xEE\xDE\x55"
			append replace "\x1D\x5E\xFB\xE7\xC5\xD3\x4A\xD6\x0F\x9F\xBC\x46\xA5\x97\x7F\xCE"
			append replace "\xAB\x28\x4C\xA5\x49\xB2\xDE\x9A\xA5\xC9\x03\xB7\x56\x52\xF7\x8D"
			append replace "\x19\x2F\x8F\x4A\x8F\x3C\xD9\x92\x09\x41\x5C\x0A\x84\xC5\xC9\xFD"
			append replace "\x6B\xF3\x09\x5C\x1C\x18\xFF\xCD\x00\x00\x00\x15\x00\x00\x00\x00"
			append replace "\x2C\x9E\x89\x69\xEC\x44\xDF\xB6\xA8\x77\x1D\xC7\xF7\xFD\xFB\xCC"
			append replace "\xAF\x32\x9E\xC3\xEC\x07\x09\x00\xCA\xBB\x23\x74\x2A\x9A\x6E\x13"
			append replace "\x5A\x4C\xEF\xD5\xA9\xC3\xC0\x93\xD0\xB9\x35\x23\x76\xD1\x94\x05"
			append replace "\x6E\x82\xF6\xB5\x4A\x0E\x9D\xEB\xE4\xA8\xB3\x04\x3E\xE3\xB2\x4C"
			append replace "\xD9\xBB\xB6\x2B\x44\x16\xB0\x48\x25\x82\xE4\x19\xA2\x55\x2E\x29"
			append replace "\xAB\x4B\xEA\x0A\x4D\x7F\xA2\xD5\x00\x00\x00\x16\x00\x00\x00\x00"
			append replace "\xF6\x9E\x4A\x29\x34\xF1\x14\xD8\x9F\x38\x6C\xE7\x66\x38\x83\x66"
			append replace "\xCD\xD2\x10\xF1\xD8\x91\x3E\x3B\x97\x32\x57\xF1\x20\x1D\x63\x2B"
			append replace "\xF4\xD5\x35\x06\x93\x01\xEE\x88\x8C\xC2\xA8\x52\xDB\x65\x44\x61"
			append replace "\x1D\x7B\x97\x4D\x10\xE6\x1C\x2E\xD0\x87\xA0\x98\x15\x35\x90\x46"
			append replace "\x77\xEC\x07\xE9\x62\x60\xF8\x95\x65\xFF\x7E\xBD\xA4\xEE\x03\x5C"
			append replace "\x2A\xA9\xBC\xBD\xD5\x89\x3F\x99\x00\x00\x00\x2D\x00\x00\x00\x00"
			append replace "\x29\x80\x53\x02\xE7\xC9\x2F\x20\x40\x09\x16\x1C\xA9\x3F\x77\x6A"
			append replace "\x07\x21\x41\xA8\xC4\x6A\x10\x8E\x57\x1C\x46\xD4\x73\xA1\x76\xA3"
			append replace "\x5D\x1F\xAB\x84\x41\x07\x67\x6A\xBC\xDF\xC2\x5E\xAE\xBC\xB6\x33"
			append replace "\x09\x30\x1B\x64\x36\xC8\x5B\x53\xCB\x15\x85\x30\x0A\x3F\x1A\xF9"
			append replace "\xFB\x14\xDB\x7C\x30\x08\x8C\x46\x42\xAD\x66\xD5\xC1\x48\xB8\x99"
			append replace "\x5B\xB1\xA6\x98\xA8\xC7\x18\x27\x00\x00\x00\x25\x00\x00\x00\x00"
			append replace "\xA4\xC9\x74\x02\xCC\x8A\x71\xBC\x77\x48\x66\x1F\xE9\xCE\x7D\xF4"
			append replace "\x4D\xCE\x95\xD0\xD5\x89\x38\xA5\x9F\x47\xB9\xE9\xDB\xA7\xBF\xC3"
			append replace "\xE4\x79\x2F\x2B\x9D\xB3\x0C\xB8\xD1\x59\x60\x77\xA1\x3F\xB3\xB5"
			append replace "\x27\x33\xC8\x89\xD2\x89\x55\x0F\xE0\x0E\xAA\x5A\x47\xA3\x4C\xEF"
			append replace "\x0C\x1A\xF1\x87\x61\x0E\xB0\x7B\xA3\x5D\x2C\x09\xBB\x73\xC8\x0B"
			append replace "\x24\x4E\xB4\x14\x77\x00\xD1\xBF\x00\x00\x00\x26\x00\x00\x00\x00"
			append replace "\x98\x14\xEF\xFF\x67\xB7\x07\x4D\x1B\x26\x3B\xF8\x5B\xDC\x85\x76"
			append replace "\xCE\x9D\xEC\x91\x41\x23\x97\x1B\x16\x94\x72\xA1\xBC\x23\x87\xFA"
			append replace "\xD4\x3B\x1F\xA8\xBE\x15\x71\x4B\x30\x78\xC2\x39\x08\xBB\x2B\xCA"
			append replace "\x7D\x19\x86\xC6\xBE\xE6\xCE\x1E\x0C\x58\x93\xBD\x2D\xF2\x03\x88"
			append replace "\x1F\x40\xD5\x05\x67\x61\xCC\x3F\x1F\x2E\x9D\x9A\x37\x86\x17\xA2"
			append replace "\xDE\x40\xBA\x5F\x09\x84\x4C\xEB\x00\x00\x00\x3D\x00\x00\x00\x00"
			append replace "\x03\xB4\xC4\x21\xE0\xC0\xDE\x70\x8C\x0F\x0B\x71\xC2\x4E\x3E\xE0"
			append replace "\x43\x06\xAE\x73\x83\xD8\xC5\x62\x13\x94\xCC\xB9\x9F\xF7\xA1\x94"
			append replace "\x5A\xDB\x9E\xAF\xE8\x97\xB5\x4C\xB1\x06\x0D\x68\x85\xBE\x22\xCF"
			append replace "\x71\x50\x2A\xDB\x57\x83\x58\x3A\xB8\x8B\x2D\x5F\x23\xF4\x19\xAF"
			append replace "\x01\xC8\xB1\xE7\x2F\xCA\x1E\x69\x4A\xD4\x9F\xE3\x26\x6F\x1F\x9C"
			append replace "\x61\xEF\xC6\xF2\x9B\x35\x11\x42\x00\x00\x00\x12\x00\x00\x00\x00"			
			set offset 5
			set mask 0				
			# PATCH THE ELF BINARY
            catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"      				
		}	
		# patch 360 keys to appldr_355
		if {$::patch_appldr::options(--add-360keys-to-appldr355)} {
		
			log "Patching Application loader 3.55 to add 3.60 keys"																
			log "patching ecdsa signature check 0x09EF8 @ 3.55"
			set search    "\x12\x05\x91\x09\x24\xFF\xC0\xD0"
			set replace   "\x48\x20\xC1\x83\x35\x00\x00\x00"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
            catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"      
									 
			log "patching various checks (crapdicrap) 0x02DD0 @ 3.55"
			set search    "\x33\x7F\x8E\x00\x04\x00\x01\xD0\x21\x00\x19\x83"
			set replace   "\x00\x20\x00\x00\x48\x34\x28\x50\x48\x20\xC1\x83"
			set offset 0	
			set mask 0				
			# PATCH THE ELF BINARY
            catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"      			
						  
			log "patching key revision check 0x013AC @ 3.55"
			set search    "\x5D\x03\x03\x15"
			set replace   "\x5D\x04\x03\x15"
			set offset 0	
			set mask 0				
			# PATCH THE ELF BINARY
            catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"      		  				
			
			log "patching 2nd keytable addr r6 0x01440 @ 3.55"
			set search    "\x43\x64\x00\x06"
			set replace   "\x43\x61\x90\x06"
			set offset 0	
			set mask 0				
			# PATCH THE ELF BINARY
            catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"      	 				
			
			log "extend first keytable 0x19820 @ 3.55"
			set search    "\x00\x00\x00\x00\x00\x95\xF5\x00\x19\xE7\xA6\x8E\x34\x1F\xA7\x2E"			 
			set replace    "\x95\xF5\x00\x19\xE7\xA6\x8E\x34\x1F\xA7\x2E\xFD\xF4\xD6\x0E\xD3"
			append replace "\x76\xE2\x5C\xF4\x6B\xB4\x8D\xFD\xD1\xF0\x80\x25\x9D\xC9\x3F\x04"
			append replace "\x4A\x09\x55\xD9\x46\xDB\x70\xD6\x91\xA6\x40\xBB\x7F\xAE\xCC\x4C"
			append replace "\x6F\x8D\xF8\xEB\xD0\xA1\xD1\xDB\x08\xB3\x0D\xD3\xA9\x51\xE3\xF1"
			append replace "\xF2\x7E\x34\x03\x0B\x42\xC7\x29\xC5\x55\x55\x23\x2D\x61\xB8\x34"
			append replace "\xB8\xBD\xFF\xB0\x7E\x54\xB3\x43\x00\x00\x00\x21\x00\x00\x00\x00"
		 
			append replace "\x79\x48\x18\x39\xC4\x06\xA6\x32\xBD\xB4\xAC\x09\x3D\x73\xD9\x9A"
			append replace "\xE1\x58\x7F\x24\xCE\x7E\x69\x19\x2C\x1C\xD0\x01\x02\x74\xA8\xAB"
			append replace "\x6F\x0F\x25\xE1\xC8\xC4\xB7\xAE\x70\xDF\x96\x8B\x04\x52\x1D\xDA"
			append replace "\x94\xD1\xB7\x37\x8B\xAF\xF5\xDF\xED\x26\x92\x40\xA7\xA3\x64\xED"
			append replace "\x68\x44\x67\x41\x62\x2E\x50\xBC\x60\x79\xB6\xE6\x06\xA2\xF8\xE0"
			append replace "\xA4\xC5\x6E\x5C\xFF\x83\x65\x26\x00\x00\x00\x11\x00\x00\x00\x00"
		 
			append replace "\x4F\x89\xBE\x98\xDD\xD4\x3C\xAD\x34\x3F\x5B\xA6\xB1\xA1\x33\xB0"
			append replace "\xA9\x71\x56\x6F\x77\x04\x84\xAA\xC2\x0B\x5D\xD1\xDC\x9F\xA0\x6A"
			append replace "\x90\xC1\x27\xA9\xB4\x3B\xA9\xD8\xE8\x9F\xE6\x52\x9E\x25\x20\x6F"
			append replace "\x8C\xA6\x90\x5F\x46\x14\x8D\x7D\x8D\x84\xD2\xAF\xCE\xAE\x61\xB4"
			append replace "\x1E\x67\x50\xFC\x22\xEA\x43\x5D\xFA\x61\xFC\xE6\xF4\xF8\x60\xEE"
			append replace "\x4F\x54\xD9\x19\x6C\xA5\x29\x0E\x00\x00\x00\x13\x00\x00\x00\x00"
		 
			append replace "\xC1\xE6\xA3\x51\xFC\xED\x6A\x06\x36\xBF\xCB\x68\x01\xA0\x94\x2D"
			append replace "\xB7\xC2\x8B\xDF\xC5\xE0\xA0\x53\xA3\xF5\x2F\x52\xFC\xE9\x75\x4E"
			append replace "\xE0\x90\x81\x63\xF4\x57\x57\x64\x40\x46\x6A\xCA\xA4\x43\xAE\x7C"
			append replace "\x50\x02\x2D\x5D\x37\xC9\x79\x05\xF8\x98\xE7\x8E\x7A\xA1\x4A\x0B"
			append replace "\x5C\xAA\xD5\xCE\x81\x90\xAE\x56\x29\xA1\x0D\x6F\x0C\xF4\x17\x35"
			append replace "\x97\xB3\x7A\x95\xA7\x54\x5C\x92\x00\x00\x00\x0B\x00\x00\x00\x00"
			
			append replace "\x83\x8F\x58\x60\xCF\x97\xCD\xAD\x75\xB3\x99\xCA\x44\xF4\xC2\x14"
			append replace "\xCD\xF9\x51\xAC\x79\x52\x98\xD7\x1D\xF3\xC3\xB7\xE9\x3A\xAE\xDA"
			append replace "\x7F\xDB\xB2\xE9\x24\xD1\x82\xBB\x0D\x69\x84\x4A\xDC\x4E\xCA\x5B"
			append replace "\x1F\x14\x0E\x8E\xF8\x87\xDA\xB5\x2F\x07\x9A\x06\xE6\x91\x5A\x64"
			append replace "\x60\xB7\x5C\xD2\x56\x83\x4A\x43\xFA\x7A\xF9\x0C\x23\x06\x7A\xF4"
			append replace "\x12\xED\xAF\xE2\xC1\x77\x8D\x69\x00\x00\x00\x14\x00\x00\x00\x00"
		 
			append replace "\xC1\x09\xAB\x56\x59\x3D\xE5\xBE\x8B\xA1\x90\x57\x8E\x7D\x81\x09"
			append replace "\x34\x6E\x86\xA1\x10\x88\xB4\x2C\x72\x7E\x2B\x79\x3F\xD6\x4B\xDC"
			append replace "\x15\xD3\xF1\x91\x29\x5C\x94\xB0\x9B\x71\xEB\xDE\x08\x8A\x18\x7A"
			append replace "\xB6\xBB\x0A\x84\xC6\x49\xA9\x0D\x97\xEB\xA5\x5B\x55\x53\x66\xF5"
			append replace "\x23\x81\xBB\x38\xA8\x4C\x8B\xB7\x1D\xA5\xA5\xA0\x94\x90\x43\xC6"
			append replace "\xDB\x24\x90\x29\xA4\x31\x56\xF7\x00\x00\x00\x15\x00\x00\x00\x00"
		 
			append replace "\x6D\xFD\x7A\xFB\x47\x0D\x2B\x2C\x95\x5A\xB2\x22\x64\xB1\xFF\x3C"
			append replace "\x67\xF1\x80\x98\x3B\x26\xC0\x16\x15\xDE\x9F\x2E\xCC\xBE\x7F\x41"
			append replace "\x24\xBD\x1C\x19\xD2\xA8\x28\x6B\x8A\xCE\x39\xE4\xA3\x78\x01\xC2"
			append replace "\x71\xF4\x6A\xC3\x3F\xF8\x9D\xF5\x89\xA1\x00\xA7\xFB\x64\xCE\xAC"
			append replace "\x24\x4C\x9A\x0C\xBB\xC1\xFD\xCE\x80\xFB\x4B\xF8\xA0\xD2\xE6\x62"
			append replace "\x93\x30\x9C\xB8\xEE\x8C\xFA\x95\x00\x00\x00\x2C\x00\x00\x00\x00"
		 
			append replace "\x94\x5B\x99\xC0\xE6\x9C\xAF\x05\x58\xC5\x88\xB9\x5F\xF4\x1B\x23"
			append replace "\x26\x60\xEC\xB0\x17\x74\x1F\x32\x18\xC1\x2F\x9D\xFD\xEE\xDE\x55"
			append replace "\x1D\x5E\xFB\xE7\xC5\xD3\x4A\xD6\x0F\x9F\xBC\x46\xA5\x97\x7F\xCE"
			append replace "\xAB\x28\x4C\xA5\x49\xB2\xDE\x9A\xA5\xC9\x03\xB7\x56\x52\xF7\x8D"
			append replace "\x19\x2F\x8F\x4A\x8F\x3C\xD9\x92\x09\x41\x5C\x0A\x84\xC5\xC9\xFD"
			append replace "\x6B\xF3\x09\x5C\x1C\x18\xFF\xCD\x00\x00\x00\x15\x00\x00\x00\x00"
		 
			append replace "\x2C\x9E\x89\x69\xEC\x44\xDF\xB6\xA8\x77\x1D\xC7\xF7\xFD\xFB\xCC"
			append replace "\xAF\x32\x9E\xC3\xEC\x07\x09\x00\xCA\xBB\x23\x74\x2A\x9A\x6E\x13"
			append replace "\x5A\x4C\xEF\xD5\xA9\xC3\xC0\x93\xD0\xB9\x35\x23\x76\xD1\x94\x05"
			append replace "\x6E\x82\xF6\xB5\x4A\x0E\x9D\xEB\xE4\xA8\xB3\x04\x3E\xE3\xB2\x4C"
			append replace "\xD9\xBB\xB6\x2B\x44\x16\xB0\x48\x25\x82\xE4\x19\xA2\x55\x2E\x29"
			append replace "\xAB\x4B\xEA\x0A\x4D\x7F\xA2\xD5\x00\x00\x00\x16\x00\x00\x00\x00"
		  
			append replace "\xF6\x9E\x4A\x29\x34\xF1\x14\xD8\x9F\x38\x6C\xE7\x66\x38\x83\x66"
			append replace "\xCD\xD2\x10\xF1\xD8\x91\x3E\x3B\x97\x32\x57\xF1\x20\x1D\x63\x2B"
			append replace "\xF4\xD5\x35\x06\x93\x01\xEE\x88\x8C\xC2\xA8\x52\xDB\x65\x44\x61"
			append replace "\x1D\x7B\x97\x4D\x10\xE6\x1C\x2E\xD0\x87\xA0\x98\x15\x35\x90\x46"
			append replace "\x77\xEC\x07\xE9\x62\x60\xF8\x95\x65\xFF\x7E\xBD\xA4\xEE\x03\x5C"
			append replace "\x2A\xA9\xBC\xBD\xD5\x89\x3F\x99\x00\x00\x00\x2D\x00\x00\x00\x00"
		 
			append replace "\x29\x80\x53\x02\xE7\xC9\x2F\x20\x40\x09\x16\x1C\xA9\x3F\x77\x6A"
			append replace "\x07\x21\x41\xA8\xC4\x6A\x10\x8E\x57\x1C\x46\xD4\x73\xA1\x76\xA3"
			append replace "\x5D\x1F\xAB\x84\x41\x07\x67\x6A\xBC\xDF\xC2\x5E\xAE\xBC\xB6\x33"
			append replace "\x09\x30\x1B\x64\x36\xC8\x5B\x53\xCB\x15\x85\x30\x0A\x3F\x1A\xF9"
			append replace "\xFB\x14\xDB\x7C\x30\x08\x8C\x46\x42\xAD\x66\xD5\xC1\x48\xB8\x99"
			append replace "\x5B\xB1\xA6\x98\xA8\xC7\x18\x27\x00\x00\x00\x25\x00\x00\x00\x00"
		  
			append replace "\xA4\xC9\x74\x02\xCC\x8A\x71\xBC\x77\x48\x66\x1F\xE9\xCE\x7D\xF4"
			append replace "\x4D\xCE\x95\xD0\xD5\x89\x38\xA5\x9F\x47\xB9\xE9\xDB\xA7\xBF\xC3"
			append replace "\xE4\x79\x2F\x2B\x9D\xB3\x0C\xB8\xD1\x59\x60\x77\xA1\x3F\xB3\xB5"
			append replace "\x27\x33\xC8\x89\xD2\x89\x55\x0F\xE0\x0E\xAA\x5A\x47\xA3\x4C\xEF"
			append replace "\x0C\x1A\xF1\x87\x61\x0E\xB0\x7B\xA3\x5D\x2C\x09\xBB\x73\xC8\x0B"
			append replace "\x24\x4E\xB4\x14\x77\x00\xD1\xBF\x00\x00\x00\x26\x00\x00\x00\x00"
		 
			append replace "\x98\x14\xEF\xFF\x67\xB7\x07\x4D\x1B\x26\x3B\xF8\x5B\xDC\x85\x76"
			append replace "\xCE\x9D\xEC\x91\x41\x23\x97\x1B\x16\x94\x72\xA1\xBC\x23\x87\xFA"
			append replace "\xD4\x3B\x1F\xA8\xBE\x15\x71\x4B\x30\x78\xC2\x39\x08\xBB\x2B\xCA"
			append replace "\x7D\x19\x86\xC6\xBE\xE6\xCE\x1E\x0C\x58\x93\xBD\x2D\xF2\x03\x88"
			append replace "\x1F\x40\xD5\x05\x67\x61\xCC\x3F\x1F\x2E\x9D\x9A\x37\x86\x17\xA2"
			append replace "\xDE\x40\xBA\x5F\x09\x84\x4C\xEB\x00\x00\x00\x3D\x00\x00\x00\x00"
		 
			append replace "\x03\xB4\xC4\x21\xE0\xC0\xDE\x70\x8C\x0F\x0B\x71\xC2\x4E\x3E\xE0"
			append replace "\x43\x06\xAE\x73\x83\xD8\xC5\x62\x13\x94\xCC\xB9\x9F\xF7\xA1\x94"
			append replace "\x5A\xDB\x9E\xAF\xE8\x97\xB5\x4C\xB1\x06\x0D\x68\x85\xBE\x22\xCF"
			append replace "\x71\x50\x2A\xDB\x57\x83\x58\x3A\xB8\x8B\x2D\x5F\x23\xF4\x19\xAF"
			append replace "\x01\xC8\xB1\xE7\x2F\xCA\x1E\x69\x4A\xD4\x9F\xE3\x26\x6F\x1F\x9C"
			append replace "\x61\xEF\xC6\xF2\x9B\x35\x11\x42\x00\x00\x00\x12\x00\x00\x00\x00"
		 
			append replace "\x39\xA8\x70\x17\x3C\x22\x6E\xB8\xA3\xEE\xE9\xCA\x6F\xB6\x75\xE8"
			append replace "\x20\x39\xB2\xD0\xCC\xB2\x26\x53\xBF\xCE\x4D\xB0\x13\xBA\xEA\x03"
			append replace "\x90\x26\x6C\x98\xCB\xAA\x06\xC1\xBF\x14\x5F\xF7\x60\xEA\x1B\x45"
			append replace "\x84\xDE\x56\x92\x80\x98\x48\xE5\xAC\xBE\x25\xBE\x54\x8F\x69\x81"
			append replace "\xE3\xDB\x14\x73\x5A\x5D\xDE\x1A\x0F\xD1\xF4\x75\x86\x65\x32\xB8"
			append replace "\x62\xB1\xAB\x6A\x00\x4B\x72\x55\x00\x00\x00\x27\x00\x00\x00\x00"
		  
			append replace "\xFD\x52\xDF\xA7\xC6\xEE\xF5\x67\x96\x28\xD1\x2E\x26\x7A\xA8\x63"
			append replace "\xB9\x36\x5E\x6D\xB9\x54\x70\x94\x9C\xFD\x23\x5B\x3F\xCA\x0F\x3B"
			append replace "\x64\xF5\x02\x96\xCF\x8C\xF4\x9C\xD7\xC6\x43\x57\x28\x87\xDA\x0B"
			append replace "\x06\x96\xD6\xCC\xBD\x7C\xF5\x85\xEF\x5E\x00\xD5\x47\x50\x3C\x18"
			append replace "\x5D\x74\x21\x58\x1B\xAD\x19\x6E\x08\x17\x23\xCD\x0A\x97\xFA\x40"
			append replace "\xB2\xC0\xCD\x24\x92\xB0\xB5\xA1\x00\x00\x00\x3A\x00\x00\x00\x00"
		   
			append replace "\xA5\xE5\x1A\xD8\xF3\x2F\xFB\xDE\x80\x89\x72\xAC\xEE\x46\x39\x7F"
			append replace "\x2D\x3F\xE6\xBC\x82\x3C\x82\x18\xEF\x87\x5E\xE3\xA9\xB0\x58\x4F"
			append replace "\x7A\x20\x3D\x51\x12\xF7\x99\x97\x9D\xF0\xE1\xB8\xB5\xB5\x2A\xA4"
			append replace "\x50\x59\x7B\x7F\x68\x0D\xD8\x9F\x65\x94\xD9\xBD\xC0\xCB\xEE\x03"
			append replace "\x66\x6A\xB5\x36\x47\xD0\x48\x7F\x7F\x45\x2F\xE2\xDD\x02\x69\x46"
			append replace "\x31\xEA\x75\x55\x48\xC9\xE9\x34\x00\x00\x00\x25\x00\x00\x00\x00"				
			set offset 5	
			set mask 0				
			# PATCH THE ELF BINARY
            catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"      			 				
		 
			log "patching NPDRM key revision check 0x00B40 @ 3.55"
			set search    "\x5D\x03\x02\x02"
			set replace   "\x5D\x04\x02\x02"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
            catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"      			 				
		  
			log "patching NPDRM forbidden key revision table size 0x00B50 @ 3.55"
			set search    "\x1C\x02\x02\x87"
			set replace   "\x1C\x03\x02\x87"
			set offset 0	
			set mask 0				
			# PATCH THE ELF BINARY
            catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"      		 				
		 
			log "patching NPDRM forbidden key revision table 0x19720 @ 3.55"
			set search    "\x00\x02\x00\x05\x00\x08\x00\x0B\x00\x00\x00\x00\x00\x00\x00\x00"
			set replace   "\x00\x02\x00\x05\x00\x08\x00\x0B\x00\x0E\x00\x11\x00\x00\x00\x00"
			set offset 0	
			set mask 0				
			# PATCH THE ELF BINARY
            catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"      	   				
		   
			log "patching 2nd keytable addr r11 0x01518 @ 3.55"
			set search    "\x43\x69\x10\x0B"
			set replace   "\x43\x66\xA0\x0B"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
            catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"      	 				
		 
			log "extend first NPDRM keytable 0x1A240 @ 3.55"
			set search    "\x23\x00\x00\x00\x00\x8E\x73\x72\x30\xC8\x0E\x66\xAD\x01\x62\xED"
			
			set replace "\x8E\x73\x72\x30\xC8\x0E\x66\xAD\x01\x62\xED\xDD\x32\xF1\xF7\x74"
			append replace "\xEE\x5E\x4E\x18\x74\x49\xF1\x90\x79\x43\x7A\x50\x8F\xCF\x9C\x86"
			append replace "\x7A\xAE\xCC\x60\xAD\x12\xAE\xD9\x0C\x34\x8D\x8C\x11\xD2\xBE\xD5"
			append replace "\x05\xBF\x09\xCB\x6F\xD7\x80\x50\xC7\x8D\xE6\x9C\xC3\x16\xFF\x27"
			append replace "\xC9\xF1\xED\x66\xA4\x5B\xFC\xE0\xA1\xE5\xA6\x74\x9B\x19\xBD\x54"
			append replace "\x6B\xBB\x46\x02\xCF\x37\x34\x40\x00\x00\x00\x0A\x00\x00\x00\x00"
			
			append replace "\xF9\xED\xD0\x30\x1F\x77\x0F\xAB\xBA\x88\x63\xD9\x89\x7F\x0F\xEA"
			append replace "\x65\x51\xB0\x94\x31\xF6\x13\x12\x65\x4E\x28\xF4\x35\x33\xEA\x6B"
			append replace "\xA5\x51\xCC\xB4\xA4\x2C\x37\xA7\x34\xA2\xB4\xF9\x65\x7D\x55\x40"
			append replace "\xB0\x5F\x9D\xA5\xF9\x12\x1E\xE4\x03\x14\x67\xE7\x4C\x50\x5C\x29"
			append replace "\xA8\xE2\x9D\x10\x22\x37\x9E\xDF\xF0\x50\x0B\x9A\xE4\x80\xB5\xDA"
			append replace "\xB4\x57\x8A\x4C\x61\xC5\xD6\xBF\x00\x00\x00\x11\x00\x00\x00\x00"
			
			append replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
			append replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
			append replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
			append replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
			append replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
			append replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
			
			append replace "\x1B\x71\x5B\x0C\x3E\x8D\xC4\xC1\xA5\x77\x2E\xBA\x9C\x5D\x34\xF7"
			append replace "\xCC\xFE\x5B\x82\x02\x5D\x45\x3F\x31\x67\x56\x64\x97\x23\x96\x64"
			append replace "\xE3\x1E\x20\x6F\xBB\x8A\xEA\x27\xFA\xB0\xD9\xA2\xFF\xB6\xB6\x2F"
			append replace "\x3F\x51\xE5\x9F\xC7\x4D\x66\x18\xD3\x44\x31\xFA\x67\x98\x7F\xA1"
			append replace "\x1A\xBB\xFA\xCC\x71\x11\x81\x14\x73\xCD\x99\x88\xFE\x91\xC4\x3F"
			append replace "\xC7\x46\x05\xE7\xB8\xCB\x73\x2D\x00\x00\x00\x08\x00\x00\x00\x00"
			
			append replace "\xBB\x4D\xBF\x66\xB7\x44\xA3\x39\x34\x17\x2D\x9F\x83\x79\xA7\xA5"
			append replace "\xEA\x74\xCB\x0F\x55\x9B\xB9\x5D\x0E\x7A\xEC\xE9\x17\x02\xB7\x06"
			append replace "\xAD\xF7\xB2\x07\xA1\x5A\xC6\x01\x11\x0E\x61\xDD\xFC\x21\x0A\xF6"
			append replace "\x9C\x32\x74\x71\xBA\xFF\x1F\x87\x7A\xE4\xFE\x29\xF4\x50\x1A\xF5"
			append replace "\xAD\x6A\x2C\x45\x9F\x86\x22\x69\x7F\x58\x3E\xFC\xA2\xCA\x30\xAB"
			append replace "\xB5\xCD\x45\xD1\x13\x1C\xAB\x30\x00\x00\x00\x16\x00\x00\x00\x00"
			
			append replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
			append replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
			append replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
			append replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
			append replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
			append replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
			
			append replace "\x8B\x4C\x52\x84\x97\x65\xD2\xB5\xFA\x3D\x56\x28\xAF\xB1\x76\x44"
			append replace "\xD5\x2B\x9F\xFE\xE2\x35\xB4\xC0\xDB\x72\xA6\x28\x67\xEA\xA0\x20"
			append replace "\x05\x71\x9D\xF1\xB1\xD0\x30\x6C\x03\x91\x0A\xDD\xCE\x4A\xF8\x87"
			append replace "\x2A\x5D\x6C\x69\x08\xCA\x98\xFC\x47\x40\xD8\x34\xC6\x40\x0E\x6D"
			append replace "\x6A\xD7\x4C\xF0\xA7\x12\xCF\x1E\x7D\xAE\x80\x6E\x98\x60\x5C\xC3"
			append replace "\x08\xF6\xA0\x36\x58\xF2\x97\x0E\x00\x00\x00\x29\x00\x00\x00\x00"
			
			append replace "\x39\x46\xDF\xAA\x14\x17\x18\xC7\xBE\x33\x9A\x0D\x6C\x26\x30\x1C"
			append replace "\x76\xB5\x68\xAE\xBC\x5C\xD5\x26\x52\xF2\xE2\xE0\x29\x74\x37\xC3"
			append replace "\xE4\x89\x7B\xE5\x53\xAE\x02\x5C\xDC\xBF\x2B\x15\xD1\xC9\x23\x4E"
			append replace "\xA1\x3A\xFE\x8B\x63\xF8\x97\xDA\x2D\x3D\xC3\x98\x7B\x39\x38\x9D"
			append replace "\xC1\x0B\xAD\x99\xDF\xB7\x03\x83\x8C\x4A\x0B\xC4\xE8\xBB\x44\x65"
			append replace "\x9C\x72\x6C\xFD\x0C\xE6\x0D\x0E\x00\x00\x00\x17\x00\x00\x00\x00"
			
			append replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
			append replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
			append replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
			append replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
			append replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
			append replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
			
			append replace "\x07\x86\xF4\xB0\xCA\x59\x37\xF5\x15\xBD\xCE\x18\x8F\x56\x9B\x2E"
			append replace "\xF3\x10\x9A\x4D\xA0\x78\x0A\x7A\xA0\x7B\xD8\x9C\x33\x50\x81\x0A"
			append replace "\x04\xAD\x3C\x2F\x12\x2A\x3B\x35\xE8\x04\x85\x0C\xAD\x14\x2C\x6D"
			append replace "\xA1\xFE\x61\x03\x5D\xBB\xEA\x5A\x94\xD1\x20\xD0\x3C\x00\x0D\x3B"
			append replace "\x2F\x08\x4B\x9F\x4A\xFA\x99\xA2\xD4\xA5\x88\xDF\x92\xB8\xF3\x63"
			append replace "\x27\xCE\x9E\x47\x88\x9A\x45\xD0\x00\x00\x00\x2A\x00\x00\x00\x00"
			
			append replace "\x03\xC2\x1A\xD7\x8F\xBB\x6A\x3D\x42\x5E\x9A\xAB\x12\x98\xF9\xFD"
			append replace "\x70\xE2\x9F\xD4\xE6\xE3\xA3\xC1\x51\x20\x5D\xA5\x0C\x41\x3D\xE4"
			append replace "\x0A\x99\xD4\xD4\xF8\x30\x1A\x88\x05\x2D\x71\x4A\xD2\xFB\x56\x5E"
			append replace "\x39\x95\xC3\x90\xC9\xF7\xFB\xBA\xB1\x24\xA1\xC1\x4E\x70\xF9\x74"
			append replace "\x1A\x5E\x6B\xDF\x17\xA6\x05\xD8\x82\x39\x65\x2C\x8E\xA7\xD5\xFC"
			append replace "\x9F\x24\xB3\x05\x46\xC1\xE4\x4B\x00\x00\x00\x27\x00\x00\x00\x00"
			
			append replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
			append replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
			append replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
			append replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
			append replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
			append replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
			
			append replace "\x35\x7E\xBB\xEA\x26\x5F\xAE\xC2\x71\x18\x2D\x57\x1C\x6C\xD2\xF6"
			append replace "\x2C\xFA\x04\xD3\x25\x58\x8F\x21\x3D\xB6\xB2\xE0\xED\x16\x6D\x92"
			append replace "\xD2\x6E\x6D\xD2\xB7\x4C\xD7\x8E\x86\x6E\x74\x2E\x55\x71\xB8\x4F"
			append replace "\x00\xDC\xF5\x39\x16\x18\x60\x4A\xB4\x2C\x8C\xFF\x3D\xC3\x04\xDF"
			append replace "\x45\x34\x1E\xBA\x45\x51\x29\x3E\x9E\x2B\x68\xFF\xE2\xDF\x52\x7F"
			append replace "\xFA\x3B\xE8\x32\x9E\x01\x5E\x57\x00\x00\x00\x3A\x00\x00\x00\x00"
			
			append replace "\x33\x7A\x51\x41\x61\x05\xB5\x6E\x40\xD7\xCA\xF1\xB9\x54\xCD\xAF"
			append replace "\x4E\x76\x45\xF2\x83\x79\x90\x4F\x35\xF2\x7E\x81\xCA\x7B\x69\x57"
			append replace "\x84\x05\xC8\x8E\x04\x22\x80\xDB\xD7\x94\xEC\x7E\x22\xB7\x40\x02"
			append replace "\x9B\xFF\x1C\xC7\x11\x8D\x23\x93\xDE\x50\xD5\xCF\x44\x90\x98\x60"
			append replace "\x68\x34\x11\xA5\x32\x76\x7B\xFD\xAC\x78\x62\x2D\xB9\xE5\x45\x67"
			append replace "\x53\xFE\x42\x2C\xBA\xFA\x1D\xA1\x00\x00\x00\x18\x00\x00\x00\x00"
			
			append replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
			append replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
			append replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
			append replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
			append replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
			append replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
			
			append replace "\x13\x5C\x09\x8C\xBE\x6A\x3E\x03\x7E\xBE\x9F\x2B\xB9\xB3\x02\x18"
			append replace "\xDD\xE8\xD6\x82\x17\x34\x6F\x9A\xD3\x32\x03\x35\x2F\xBB\x32\x91"
			append replace "\x40\x70\xC8\x98\xC2\xEA\xAD\x16\x34\xA2\x88\xAA\x54\x7A\x35\xA8"
			append replace "\xBB\xD7\xCC\xCB\x55\x6C\x2E\xF0\xF9\x08\xDC\x78\x10\xFA\xFC\x37"
			append replace "\xF2\xE5\x6B\x3D\xAA\x5F\x7F\xAF\x53\xA4\x94\x4A\xA9\xB8\x41\xF7"
			append replace "\x6A\xB0\x91\xE1\x6B\x23\x14\x33\x00\x00\x00\x3B\x00\x00\x00\x00"
			
			append replace "\x4B\x3C\xD1\x0F\x6A\x6A\xA7\xD9\x9F\x9B\x3A\x66\x0C\x35\xAD\xE0"
			append replace "\x8E\xF0\x1C\x2C\x33\x6B\x9E\x46\xD1\xBB\x56\x78\xB4\x26\x1A\x61"
			append replace "\xC0\xF2\xAB\x86\xE6\xE0\x45\x75\x52\xDB\x50\xD7\x21\x93\x71\xC5"
			append replace "\x64\xA5\xC6\x0B\xC2\xAD\x18\xB8\xA2\x37\xE4\xAA\x69\x06\x47\xE1"
			append replace "\x2B\xF7\xA0\x81\x52\x3F\xAD\x4F\x29\xBE\x89\xAC\xAC\x72\xF7\xAB"
			append replace "\x43\xC7\x4E\xC9\xAF\xFD\xA2\x13\x00\x00\x00\x27\x00\x00\x00\x00"
			
			append replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
			append replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
			append replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
			append replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
			append replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
			append replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
			
			append replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
			append replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
			append replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
			append replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
			append replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
			append replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"			
			set offset 5
			set mask 0	
			
			# PATCH THE ELF BINARY
            catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"           					
		}		
	}  
	##
	################################################################################################################################################
}
