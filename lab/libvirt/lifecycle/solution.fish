#!/bin/fish
virsh start student-vm >/dev/null 2>/dev/null; or true
virsh suspend student-vm >/dev/null 2>/dev/null; or true
virsh resume student-vm >/dev/null 2>/dev/null; or true
virsh shutdown student-vm >/dev/null 2>/dev/null; or virsh destroy student-vm >/dev/null 2>/dev/null; or true
