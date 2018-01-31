align 4TVP_G, 4TVP_G, object=GG
save E:/temp\unliganded\4TVP_G_4NCO_A.alin

set surface_color, white
set transparency, 0.5

set cartoon_transparency, 0.5, <object>

align (apo_model and name CA), (liganded_model and name CA)

select apo_v12, apo_model and name CA and resi 101-164

align (apo_model and name CA and resi 165-263 or resi 298-350 or resi 381-422), (liganded_model and name CA and resi 165-263 or resi 298-350 or resi 381-422)

select liganded_core, liganded_model and name CA and resi 165-263 or resi 298-350 or resi 381-422

set cartoon_gap_cutoff, 20

alter 11-40/, ss='H'             # assign residues 11-40 as helix
alter 40-52/, ss='L'             # assign residues 40-52 as loop
alter 52-65/, ss='S'             # assign residues 52-65 as sheet
rebuild

color blue, ss h
color red, ss s
color yellow, ss l+''

png filename.png, dpi=600

