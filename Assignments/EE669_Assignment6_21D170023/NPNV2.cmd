# 2D NPN Vertical Bipolar Transistor
#-----------------------------------
math coord.ucs
line x loc= 2.0<um>
line x loc= 4.0<um> tag=SubTop
line x loc= 6.0<um>
line x loc= 10.0<um> tag=SubBottom
line y loc= 0.0<um> tag=SubLeft
line y loc=1.5<um>
line y loc=2.5<um>
line y loc=8<um>
line y loc=13<um>
line y loc=22<um>
line y loc=24<um>
line y loc=30.0<um> tag=SubRight
# Diffuse settings to speed up simulation
#----------------------------------------
pdbSet Diffuse IncreaseRatio 8.0
pdbSet Diffuse ReduceRatio 0.5
# Mesh settings
#--------------
mgoals normal.growth.ratio=2.0 accuracy=2e-5 min.normal.size=10<nm> \
max.lateral.size=30.0<um> minedge=1e-5
pdbSet Grid Adaptive 1
pdbSet Grid AdaptiveField Refine.Abs.Error 1e25
pdbSet Grid AdaptiveField Refine.Rel.Error 2.0
pdbSet Grid Damage Refine.Min.Value 1e25
pdbSet Grid Damage Refine.Max.Value 1e25
pdbSet Grid Damage Refine.Target.Length 1
pdbSet Diffuse Compute.Regrid.Steps 10
pdbSet Grid Refine.Percent 0.01

refinebox interface.mat.pairs= {Silicon Oxide}
refinebox name=BL refine.fields= {Antimony Phosphorus} \
rel.error={Antimony=0.6 Phosphorus=0.6} \

abs.error= {Antimony=1e16 Phosphorus=1e16} \
Adaptive min= "2.0 -0.1" max= "10.1 30.1" \
refine.min.edge= {0.2 0.4} max.dose.error= {Antimony=1e8}
refinebox name=Sinker refine.fields= {Phosphorus Arsenic} \
rel.error= {Phosphorus=0.5 Arsenic=0.5} \
abs.error= {Phosphorus=5e15 Arsenic=1e16} \
Adaptive min= {-1.0 16} max= {2.0 30.1} refine.min.edge= {0.1 0.2}
refinebox name=Active refine.fields= {Boron Arsenic} \
rel.error= {Boron=0.5 Arsenic=0.5} \
abs.error= {Boron=2e15 Arsenic=1e16} \
Adaptive min= {-1.0 -0.1} max= {2.0 16.0} \
refine.min.edge= {0.025 0.05}
# Masks definition
#-----------------
mask name=Sinker segments= {-1 22 24 35} negative
mask name=Base segments= {-1 1.5 13 35} negative
mask name=Emitter segments= {-1 2.5 8 22 24 35} negative
mask name=Contact segments= {-1 3.5 7 10 12 22.5 23.5 35}
mask name=Metal segments= {-1 2 8 9 13 22 24 35} negative
# Creating initial structure
#---------------------------
region Silicon xlo=SubTop xhi=SubBottom ylo=SubLeft yhi=SubRight
init concentration=1e+15<cm-3> field=Boron
# Buried layer
#-------------
deposit material= {Oxide} type=isotropic time=1 rate= {0.025}
implant Antimony dose=1.5e15<cm-2> energy=100<keV>
etch material= {Oxide} type=anisotropic time=1 rate= {0.03}
# Epi layer
#----------
deposit material= {Silicon} type=isotropic time=1 rate= {4.0} \
Arsenic concentration=1e15<cm-3>
diffuse temp=1100<C> time=60<min> maxstep=4<min>
struct tdr=vert_npn1
SetPlxList {BTotal SbTotal AsTotal PTotal}
WritePlx Buried.plx 

# Sinker
#-------
deposit material= {Oxide} type=isotropic time=1 rate= {0.05}
photo mask=Sinker thickness=1
implant Phosphorus dose=5e15<cm-2> energy=200<keV>
strip Resist
diffuse temp=1100<C> time=5<hr> maxstep=8<min>
struct tdr=vert_npn2
# Base
#-----
photo mask=Base thickness=1
implant Boron dose=1e14<cm-2> energy=50<keV>
strip Resist
diffuse temp=1100<C> time=35<min> maxstep=4<min>
struct tdr=vert_npn3
# Emitter
#--------
photo mask=Emitter thickness=1
implant Arsenic dose=5e15<cm-2> energy=55<keV> tilt=7 rotation=0
strip Resist
diffuse temp=1100<C> time=25<min> maxstep=4<min>
struct tdr=vert_npn4
SetPlxList {BTotal SbTotal AsTotal PTotal}
WritePlx Final.plx y=5.0
WritePlx Sinker.plx y=23.0
# Back end
#---------
etch material= {Oxide} type=anisotropic time=1 rate= {0.055} mask=Contact
deposit material= {Aluminum} type=isotropic time=1 rate= {1.0}
etch material= {Aluminum} type=anisotropic time=1 rate= {1.1} mask=Metal
struct tdr=vert_npn5
exit