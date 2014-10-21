#!/usr/bin/perl

use strict;
use warnings;

use English qw(-no_match_vars);
use Test::More;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Task::Inventory::Input::Generic::Screen;

my %tests = (
    'crt.13' => {
        MANUFACTURER => 'Lite-On',
        CAPTION      => 'A1554NEL',
        SERIAL       => '926750447',
        DESCRIPTION  => '26/1999'
    },
    'crt.dell-d1626ht' => {
        MANUFACTURER => 'Dell Computer Corp.',
        CAPTION      => 'DELL D1626HT',
        SERIAL       => '55347B06Z418',
        DESCRIPTION  => '4/1998'
    },
    'crt.dell-p1110' => {
        MANUFACTURER => 'Dell Computer Corp.',
        CAPTION      => 'DELL P1110',
        SERIAL       => '9171RB0JCW89',
        DESCRIPTION  => '35/1999'
    },
    'crt.dell-p790' => {
        MANUFACTURER => 'Dell Computer Corp.',
        CAPTION      => 'DELL P790',
        SERIAL       => '8757RH9QUY80',
        DESCRIPTION  => '33/2000'
    },
    'crt.dell-p190s' => {
        MANUFACTURER => 'Dell Computer Corp.',
        CAPTION      => 'DELL P190S',
        SERIAL       => 'CHRYK07UAGUS',
        DESCRIPTION  => '30/2010'
    },
    'crt.dell-e190s' => {
        MANUFACTURER => 'Dell Computer Corp.',
        CAPTION      => 'DELL E190S',
        SERIAL       => 'G448N08G0RYS',
        DESCRIPTION  => '34/2010'
    },
    'crt.E55' => {
        MANUFACTURER => 'Panasonic Comm. & Systems Co.',
        CAPTION      => undef,
        SERIAL       => '000018a6',
        DESCRIPTION  => '10/1999'
    },
    'crt.emc0313' => {
        MANUFACTURER => 'EMC',
        CAPTION      => undef,
        SERIAL       => '0000198a',
        DESCRIPTION  => '21/2001'
    },
    'crt.hyundai-ImageQuest-L70S+' => {
        MANUFACTURER => 'Hyundai',
        CAPTION      => 'L70S+',
        SERIAL       => '0000e0eb',
        DESCRIPTION  => '44/2004'
    },
    'crt.iiyama-1451' => {
        MANUFACTURER => 'Idek Iiyama North America, Inc.',
        CAPTION      => 'LS902U',
        SERIAL       => '0001f7be',
        DESCRIPTION  => '3/2003'
    },
    'crt.iiyama-404' => {
        MANUFACTURER => 'Idek Iiyama North America, Inc.',
        CAPTION      => undef,
        SERIAL       => '00000000',
        DESCRIPTION  => '52/1999'
    },
    'crt.iiyama-410pro' => {
        MANUFACTURER => 'Idek Iiyama North America, Inc.',
        CAPTION      => undef,
        SERIAL       => '00000000',
        DESCRIPTION  => '38/2000'
    },
    'crt.leia' => {
        MANUFACTURER => 'COMPAQ Computer Corp.',
        CAPTION      => 'COMPAQ P710',
        SERIAL       => '047ch67ha005',
        DESCRIPTION  => '47/2000'
    },
    'crt.LG-Studioworks-N2200P' => {
        MANUFACTURER => 'LG Electronics Inc. (GoldStar Technology, Inc.)',
        CAPTION      => 'Studioworks N 2200P',
        SERIAL       => '0000ce6e',
        DESCRIPTION  => '10/2004'
    },
    'crt.med2914' => {
        MANUFACTURER => 'MED',
        CAPTION      => undef,
        SERIAL       => '108371572',
        DESCRIPTION  => '8/2001'
    },
    'crt.nokia-valuegraph-447w' => {
        MANUFACTURER => 'Nokia',
        CAPTION      => undef,
        SERIAL       => '00000d1b',
        DESCRIPTION  => '6/1997'
    },
    'crt.SM550S' => {
        MANUFACTURER => 'Samsung',
        CAPTION      => undef,
        SERIAL       => 'HXAKB13419',
        DESCRIPTION  => '48/1999'
    },
    'crt.SM550V' => {
        MANUFACTURER => 'Samsung',
        CAPTION      => 'S/M 550v',
        SERIAL       => 'HXBN407938',
        DESCRIPTION  => '16/2000'
    },
    'crt.sony-gdm400ps' => {
        MANUFACTURER => 'Sony Corporation',
        CAPTION      => 'GDM-400PST9',
        SERIAL       => '6005379',
        DESCRIPTION  => '39/1999'
    },
    'crt.sony-gdm420' => {
        MANUFACTURER => 'Sony Corporation',
        CAPTION      => 'CPD-G420',
        SERIAL       => '6017706',
        DESCRIPTION  => '39/2001'
    },
    'crt.test_box_lmontel' => {
        MANUFACTURER => 'COMPAQ Computer Corp.',
        CAPTION      => 'COMPAQ MV920',
        SERIAL       => '008GA23MA966',
        DESCRIPTION  => '8/2000'
    },
    'lcd.20inches' => {
        MANUFACTURER => 'Maxdata Computer GmbH',
        CAPTION      => 'B102005',
        SERIAL       => '0000033f',
        DESCRIPTION  => '52/2004'
    },
    'lcd.acer-al1921' => {
        MANUFACTURER => 'Acer America Corp.',
        CAPTION      => 'Acer AL1921',
        SERIAL       => 'ETL2508043',
        DESCRIPTION  => '45/2004'
    },
    'lcd.acer-al19161.1' => {
        MANUFACTURER => 'Acer America Corp.',
        CAPTION      => 'Acer AL1916',
        SERIAL       => 'L4908669719030c64237',
        DESCRIPTION  => '19/2007'
    },
    'lcd.acer-al19161.2' => {
        MANUFACTURER => 'Acer America Corp.',
        CAPTION      => 'Acer AL1916',
        SERIAL       => 'L49086697190328f4237',
        DESCRIPTION  => '19/2007'
    },
    'lcd.acer-al19161.3' => {
        MANUFACTURER => 'Acer America Corp.',
        CAPTION      => 'Acer AL1916',
        SERIAL       => 'L4908669719032914237',
        DESCRIPTION  => '19/2007'
    },
    'lcd.acer-al19161.4' => {
        MANUFACTURER => 'Acer America Corp.',
        CAPTION      => 'Acer AL1916',
        SERIAL       => 'L4908669719032904237',
        DESCRIPTION  => '19/2007'
    },
    'lcd.acer-asp1680' => {
        MANUFACTURER => 'QDS',
        CAPTION      => undef,
        SERIAL       => '00000000',
        DESCRIPTION  => '51/2004'
    },
    'lcd.acer-v193.1' => {
        MANUFACTURER => 'Acer America Corp.',
        CAPTION      => 'Acer V193',
        SERIAL       => 'LBZ081610080b6974233',
        DESCRIPTION  => '8/2010'
    },
    'lcd.acer-v193.2' => {
        MANUFACTURER => 'Acer America Corp.',
        CAPTION      => 'Acer V193',
        SERIAL       => 'LBZ081610050c5b24233',
        DESCRIPTION  => '5/2010'
    },
    'lcd.acer-x193hq' => {
        MANUFACTURER => 'Acer America Corp.',
        CAPTION      => 'X193HQ',
        SERIAL       => 'LEK0D0998545',
        DESCRIPTION  => '40/2009'
    },
    'lcd.b-101750' => {
        MANUFACTURER => 'Maxdata Computer GmbH',
        CAPTION      => 'B_101750',
        SERIAL       => '00000219',
        DESCRIPTION  => '6/2004'
    },
    'lcd.benq-t904' => {
        MANUFACTURER => 'BenQ Corporation',
        CAPTION      => 'BenQ T904',
        SERIAL       => '0000197a',
        DESCRIPTION  => '15/2004'
    },
    'lcd.blino' => {
        MANUFACTURER => 'AU Optronics',
        CAPTION      => undef,
        SERIAL       => '00000291',
        DESCRIPTION  => '35/2004'
    },
    'lcd.cmc-17-AD' => {
        MANUFACTURER => 'CMO',
        CAPTION      => 'CMC 17" AD',
        SERIAL       => '0',
        DESCRIPTION  => '34/2004'
    },
    'lcd.compaq-evo-n1020v' => {
        MANUFACTURER => 'LGP',
        CAPTION      => undef,
        SERIAL       => '00000000',
        DESCRIPTION  => '0/1990'
    },
    'lcd.dell-2001fp' => {
        MANUFACTURER => 'Dell Computer Corp.',
        CAPTION      => 'DELL 2001FP',
        SERIAL       => 'C064652L3KTL',
        DESCRIPTION  => '9/2005'
    },
    'lcd.dell-inspiron-6400' => {
        MANUFACTURER => 'LG Philips',
        CAPTION      => undef,
        SERIAL       => '00000000',
        DESCRIPTION  => '0/2005',
    },
    'lcd.eizo-l997' => {
        MANUFACTURER => 'ENC',
        CAPTION      => 'L997',
        SERIAL       => '21211015',
        DESCRIPTION  => '5/2005'
    },
    'lcd.Elonex-PR600' => {
        MANUFACTURER => 'CMO',
        CAPTION      => undef,
        SERIAL       => '00000000',
        DESCRIPTION  => '9/2006',
    },
    'lcd.fujitsu-a171' => {
        MANUFACTURER => 'Fujitsu Siemens',
        CAPTION      => 'A17-1',
        SERIAL       => 'YEEP525344',
        DESCRIPTION  => '34/2005'
    },
    'lcd.gericom-cy-96' => {
        MANUFACTURER => 'PTS',
        CAPTION      => 'CY965',
        SERIAL       => 'F3AJ3A0019190',
        DESCRIPTION  => '41/2003',
    },
    'lcd.hp-nx-7000' => {
        MANUFACTURER => 'LGP',
        CAPTION      => undef,
        SERIAL       => '00000000',
        DESCRIPTION  => '0/2003',
    },
    'lcd.hp-nx-7010' => {
        MANUFACTURER => 'LGP',
        CAPTION      => undef,
        SERIAL       => '00000000',
        DESCRIPTION  => '0/2003',
    },
    'lcd.HP-Pavilion-ZV6000' => {
        MANUFACTURER => 'QDS',
        CAPTION      => undef,
        SERIAL       => '00000000',
        DESCRIPTION  => '51/2004',
    },
    'lcd.hp-l1950' => {
        MANUFACTURER => 'Hewlett Packard',
        CAPTION      => 'HP L1950',
        SERIAL       => 'CNK7420237',
        DESCRIPTION  => '42/2007'
    },
    'lcd.iiyama-pl2409hd' => {
        MANUFACTURER => 'Idek Iiyama North America, Inc.',
        CAPTION      => 'PL2409HD',
        SERIAL       => '11004M0C00313',
        DESCRIPTION  => '49/2010'
    },
    'lcd.lg-l1960.1' => {
        MANUFACTURER => 'LG Electronics Inc. (GoldStar Technology, Inc.)',
        CAPTION      => 'L1960TR ',
        SERIAL       => '9Y670',
        DESCRIPTION  => '11/2007'
    },
    'lcd.lg-l1960.2' => {
        MANUFACTURER => 'LG Electronics Inc. (GoldStar Technology, Inc.)',
        CAPTION      => 'L1960TR ',
        SERIAL       => '9Y676',
        DESCRIPTION  => '11/2007'
    },
    'lcd.lenovo-3000-v100' => {
        MANUFACTURER => 'AU Optronics',
        CAPTION      => undef,
        SERIAL       => '00000000',
        DESCRIPTION  => '1/2006',
    },
    'lcd.lenovo-w500' => {
        MANUFACTURER => 'Lenovo',
        CAPTION      => undef,
        SERIAL       => '00000000',
        DESCRIPTION  => '0/2007',
    },
    'lcd.philips-150s' => {
        MANUFACTURER => 'Philips Consumer Electronics Co.',
        CAPTION      => 'PHILIPS  150S',
        SERIAL       => ' HD  000237',
        DESCRIPTION  => '33/2001'
    },
    'lcd.philips-180b2' => {
        MANUFACTURER => 'Philips Consumer Electronics Co.',
        CAPTION      => 'Philips 180B2',
        SERIAL       => ' HD  021838',
        DESCRIPTION  => '42/2002'
    },
    'lcd.presario-R4000' => {
        MANUFACTURER => 'LG Philips',
        CAPTION      => undef,
        SERIAL       => '00000000',
        DESCRIPTION  => '0/2004',
    },
    'lcd.rafael' => {
        MANUFACTURER => 'Maxdata Computer GmbH',
        CAPTION      => 'B101715',
        SERIAL       => '000005e5',
        DESCRIPTION  => '27/2004',
    },
    'lcd.regis' => {
        MANUFACTURER => 'ENC',
        CAPTION      => 'L557',
        SERIAL       => '82522083',
        DESCRIPTION  => '33/2003',
    },
    'lcd.samsung-191n' => {
        MANUFACTURER => 'Samsung',
        CAPTION      => 'SyncMaster',
        SERIAL       => 'HCHW600639',
        DESCRIPTION  => '23/2003'
    },
    'lcd.samsung-2494hm' => {
        MANUFACTURER => 'Samsung',
        CAPTION      => 'SyncMaster',
        SERIAL       => 'H9XS933672',
        DESCRIPTION  => '39/2009'
    },
    'lcd.tv.VQ32-1T' => {
        MANUFACTURER => 'Fujitsu Siemens',
        CAPTION      => 'VQ32-1T',
        SERIAL       => '00000001',
        DESCRIPTION  => '40/2006',
    },
    'lcd.viewsonic-vx715' => {
        MANUFACTURER => 'ViewSonic Corporation',
        CAPTION      => 'VX715',
        SERIAL       => 'P21044404507',
        DESCRIPTION  => '44/2004'
    },
    'IMP2262' => {
        MANUFACTURER => 'IMP',
        CAPTION      => '*22W1*',
        SERIAL       => '74701944',
        DESCRIPTION  => '47/2007'
    },
);

plan tests => scalar keys %tests;

foreach my $test (sort keys %tests) {
    my $file = "resources/generic/edid/$test";
    my $edid = getAllLines(file => $file);
    my $info = FusionInventory::Agent::Task::Inventory::Input::Generic::Screen::_getEdidInfo($edid);
    is_deeply($info, $tests{$test}, $test);
}
