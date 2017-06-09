clear
close all
clc

toshow{1,1} = '1';
toshow{1,2} = 2;
toshow{1,3} = {};
toshow{1,5} = [];
toshow{1,4} = struct;
toshow{2,1}{1,1} = '11';
toshow{2,1}{1,2} = '11';
toshow{2,1}{2,1} = '11';
toshow{2,1}{2,2} = '11';
toshow{2,2}{1,1}{1,1} = 'xxx';
toshow{2,2}{1,1}{1,2} = 12;
toshow{2,4}{2,1} = {};
toshow{2,2}{2,2} = struct;
toshow{2,3}{1,2} = '22';
toshow{2,3}{1,2,6} = '66';

celldisp(toshow)
cellplot(toshow)
ShowCellTree(toshow)