
#Porcupine plot by Robert Schulz
#Copyright 2009

#Description
#	VMD script to calculate the distances between atoms of molecules/frames
#	and to draw them as arrows as well as to write the value to the user attribute
#Input data:
#	2 molecules/frames or a trajectory loaded into VMD

# 1: source porcupineplot.tcl
# 2: execute the individual procedures with the input selection(s)
# 2b: OR "ask" PorcupineHelp

package provide porcupineplot 1.0

namespace eval ::porcupineplot:: {
	variable vecField

	#global variables required for trajectory evaluation
	set distMax 0.0
	set distMin 100000.0
	#list of colors corresponding to the BGR color scale
	set minColor 32
	set maxColor 1056
	set NrColors [expr $maxColor- $minColor]
	set colorScheme BGR

	namespace ensemble create
	namespace export Diff Traj Remove Help
}

#procedure to draw an arrow from $start to $end
proc vmd_draw_arrow {mol start end {scale 1.0} {res 10} {radius 0.2}} { 
	return [graphics $mol cone $start $end radius [expr $radius * 1.7] resolution $res ]
}

proc ::porcupineplot::SetColorScale {} {
	variable minColor
	variable maxColor
	variable NrColors
	variable colorScheme
	color scale method $colorScheme
	color scale min 0
	color scale max 1
	color scale midpoint 0.5

	set minColor [expr [colorinfo num]]
	set maxColor [expr [colorinfo max] - 1]
	set NrColors [expr $maxColor- $minColor- 1]
}

#procedure to draw the corresponding ColorScaleBar
proc ::porcupineplot::ColorScaleBar {distRange} {
	variable distMin
	variable distMax
	variable NrColors
	if {$distRange > 0.0} {
		puts "drawing color scale bar"

		ColorScaleBar::color_scale_bar 0.8 0.05 0 1 $distMin $distMax 4
	} else {
		::ColorScaleBar::delete_color_scale_bar
	}
}

#procedure to  draw arrows for each residue between two states
proc ::porcupineplot::DrawColoredArrow {mol listVecs distRange arrowRes} {
	variable distMin
	variable distMax
	variable minColor
	variable NrColors
	variable colorScheme
	variable vecField

	Remove

	puts "drawing arrows for distances between $distMin and $distMax (colors from scheme $colorScheme)"

	SetColorScale
	set midColor [expr $NrColors* 0.5]

	foreach vec $listVecs {
		set dist [veclength [vecsub [lindex $vec 0] [lindex $vec 1]]]

		if {($dist >= $distMin && $dist <= $distMax)} {
	#set arrow colors dependent on length
		if {$distRange > 0.0} {
			set distcolor [expr int(double($NrColors) * double($dist - $distMin) / double($distRange))]
			if {$distcolor < 0} {
				set distcolor 0
			} elseif {$distcolor >= $NrColors} {
				set distcolor [expr $NrColors - 1]
			}
			draw color [expr $minColor + $distcolor]
		} else {
			draw color [expr $minColor + $midColor]
		}
		lappend vecField [vmd_draw_arrow $mol [lindex $vec 0] [lindex $vec 1] 1.0 $arrowRes 0.2]
		}
	}
}

#procedure to calculate and draw distances between residues in two different conformations
proc ::porcupineplot::Diff {selFirst selSecond args} {
	variable distMax
	variable distMin
	variable NrColors

	set argc [llength $args]

	set MinSet -1
	set MaxSet -1
	set arrowRes 20
	set trajMode 0
	set resOffset 0
	set resSel "residue"

	set listVecs {}

	set distMax 0.0
	set distMin 100000.0

#read arguments
  if {$argc > 0} {
	 for {set i 0} {$i < $argc} {incr i} {
		set arg [lindex $args $i]
		#offset for resid between the selections
		if { [string match "-resoffset" $arg] } {
		  incr i
		  set resOffset [lindex $args $i]
		#selection of a residue
		} elseif { [string match "-ressel" $arg] } {
		  incr i
		  set resSel [lindex $args $i]
		#distance minimum
		} elseif { [string match "-min" $arg] } {
		  incr i
		  set MinSet [expr double([lindex $args $i])]
		#distance maximum
		} elseif { [string match "-max" $arg] } {
		  incr i
		  set MaxSet [expr double([lindex $args $i])]
		#resolution of arrows
		} elseif { [string match "-arrowres" $arg] } {
		  incr i
		  set arrowRes [expr int([lindex $args $i])]
		#switch for trajectory mode
		} elseif { [string match "-traj" $arg] } {
		  set trajMode 1
		} 
	 }
  }
#break if input arguments are missing
  if { $selFirst == "" || $selSecond == ""} {
	 puts "first 2 are mandatory arguments:"
	 puts "1st atom selection as starting point in space"
	 puts "2nd atom selection as final point in space"
	 puts "Optional arguments:"
	 puts "-min: Range min"
	 puts "-max: Range max"
	 puts "-arrowres: arrow resolution"
	 puts "-ressel: residue selection (resid/residue)"
	 return
  }

#read selection properties
  set molFirst [$selFirst molid]
  set molSecond [$selSecond molid]
  mol top $molFirst

  set frameFirst [$selFirst frame]
  set frameSecond [$selSecond frame]

  set textFirst [$selFirst text]
  set textSecond [$selSecond text]

  #read residue list
  set listRes [lsort -u -integer [$selFirst get $resSel]]

  if {[$selFirst num] == 0} {
	 puts "Wrong selection 1: no atoms found"
	 return
  }
	if {[$selSecond num] == 0} {
		puts "Wrong selection 2: no atoms found"
		return
	}

	if {$trajMode == 0} {
		puts "running through [llength $listRes] residues"
	}
	foreach res $listRes {
		#selections per residue
		set selResFirst [atomselect $molFirst "$resSel $res and $textFirst" frame $frameFirst]
		set selResSecond [atomselect $molSecond "$resSel [expr $res+ $resOffset] and $textSecond" frame $frameSecond]

		#write current positions to list
		if {[$selResFirst num] > 0 && [$selResSecond num] > 0} {
			foreach coordFirst [$selResFirst get {x y z}] coordSecond [$selResSecond get {x y z}] {
			lappend listVecs [list $coordFirst $coordSecond]
			set dist [veclength [vecsub $coordFirst $coordSecond]]
			$selResFirst set user $dist
			$selResSecond set user $dist
			if {$dist > $distMax} {
				set distMax $dist
			}
			if {$dist < $distMin} {
				set distMin $dist
			}
			}
		}

		$selResFirst delete
		$selResSecond delete
	}
	if {$MinSet != -1} {
		set distMin $MinSet
	}
	if {$MaxSet != -1} {
		set distMax $MaxSet
	}
	if {$trajMode == 1} {
		return $listVecs
	}

	if {[llength $listVecs] > 0} {
		set distRange [expr $distMax- $distMin]

		DrawColoredArrow $molFirst $listVecs $distRange $arrowRes

	 ColorScaleBar $distRange
	}
		puts "done"
}

#procedure to draw the progress of a trajectory using PorcupineDiff
proc ::porcupineplot::Traj {selTraj args} {
	variable distMax
	variable distMin
	variable NrColors
	set argc [llength $args]

	set minTraj 100000
	set maxTraj 0
	set resOffset 0
	set resSel residue

	set MinSet -1
	set MaxSet -1
	set arrowRes 20

	set listVecs {}

	set numFrames [molinfo top get numframes]
	set frFirst 0
	set frLast [expr $numFrames- 1]

#read arguments
	if {$argc > 0} {
		for {set i 0} {$i < $argc} {incr i} {
			set arg [lindex $args $i]
			#offset for resid between the selections
			if { [string match "-resoffset" $arg] } {
				incr i
				set resOffset [lindex $args $i]
			#selection of a residue
			} elseif { [string match "-ressel" $arg] } {
				incr i
				set resSel [lindex $args $i]
			#first frame
			} elseif { [string match "-first" $arg] } {
				incr i
				set frFirst [expr int([lindex $args $i])]
			#last frame
			} elseif { [string match "-last" $arg] } {
				incr i
				set frLast [expr int([lindex $args $i])]
			#distance minimum
			} elseif { [string match "-min" $arg] } {
				incr i
				set MinSet [expr double([lindex $args $i])]
			#distance maximum
			} elseif { [string match "-max" $arg] } {
				incr i
				set MaxSet [expr double([lindex $args $i])]
			} elseif { [string match "-arrowres" $arg] } {
				incr i
				set arrowRes [expr int([lindex $args $i])]
			}
		}
	}
	if { $selTraj == "" } {
		puts "Mandatory arguments:"
		puts "1st argument: atom selection"
		puts "Optional arguments:"
		puts "-first: first frame"
		puts "-last: last frame"
		puts "-min: Range min"
		puts "-max: Range max"
		puts "-arrowres: arrow resolution"
		puts "-ressel: residue selection"
		return
	}

	set molTraj [$selTraj molid]
	set textTraj [$selTraj text]
	puts "looping over [expr $frLast-$frFirst+1] frames"
	set sel1 [atomselect $molTraj $textTraj]
	set sel2 [atomselect $molTraj $textTraj]

	if {[$sel1 num] == 0} {
		puts "Wrong selection: no atoms found"
		return
	}

	for {set iFrame $frFirst} { $iFrame < $frLast } {incr iFrame} {
		$sel1 frame $iFrame
		$sel2 frame [expr $iFrame + 1]

		set listVecTemp [Diff $sel1 $sel2 -resoffset $resOffset -min $MinSet -max $MaxSet -arrowres $arrowRes -ressel $resSel -traj]

		if {$distMax > $maxTraj} {
			set maxTraj $distMax
		}
		if {$distMin < $minTraj} {
			set minTraj $distMin
		}
		foreach elem $listVecTemp {
			lappend listVecs $elem
		}
	}
	$sel1 delete
	$sel2 delete

	if {[llength $listVecs] > 0} {
		if {$MaxSet != -1} {
			set distMax $MaxSet
		} else {
			set distMax $maxTraj
		}
		if {$MinSet != -1} {
			set distMin $MinSet
		} else {
			set distMin $minTraj
		}
		set distRange [expr $distMax- $distMin]

		puts "drawing arrows"
		DrawColoredArrow $molTraj $listVecs $distRange $arrowRes
		puts "putting scale bar"
		ColorScaleBar $distRange
	}
	puts "done"
}

#procedure to delete previously drawn arrows which have been stored in OldField
proc ::porcupineplot::Remove {} {
	variable vecField

	if {[info exists vecField] != 0 && $vecField != ""} {
		foreach arrow $vecField {
			draw delete [expr $arrow -1]
			draw delete $arrow
		}
		set vecField {}
		::ColorScaleBar::delete_color_scale_bar
	}
}

proc ::porcupineplot::Help {} {
	puts "\tporcupineplot contains 3 executable procedures:"
	puts "Diff  draws the linear interpolation between two indivual states; also between different VMD molecules"
	puts "Traj  draws linear interpolations between several states within one VMD molecule"
	puts "Remove  deletes the previously drawn arrows in the VMD window"
	puts ""
	puts "\tDiff:"
	puts "first 2 are mandatory arguments:"
	puts "1st atom selection as starting point in space"
	puts "2nd atom selection as final point in space"
	puts "Optional arguments:"
	puts "-min: Range min"
	puts "-max: Range max"
	puts "-arrowres: arrow resolution"
	puts "-ressel: residue selection (resid/residue)"
	puts ""
	puts "\tTraj:"
	puts "Mandatory arguments:"
	puts "1st argument: atom selection"
	puts "Optional arguments:"
	puts "-first: first frame"
	puts "-last: last frame"
	puts "-min: Range min"
	puts "-max: Range max"
	puts "-arrowres: arrow resolution"
	puts "-ressel: residue selection"
}
