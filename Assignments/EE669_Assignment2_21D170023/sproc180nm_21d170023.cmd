# Sentaurus sprocess file for EE669 assignment 2 - 21D170023

#_____________________________Code start___________________________#

###________________Initial 2D Grid and Simulation Domain____________###

#  Initial 2D grid is defined with line command 

# Defining the top Si layers
line x location= 0.0      spacing= 1.0<nm>  tag= SiTop     

# These are intermediate layers defined for precision in computation
# They are defined in such a non-linear way since the top is where
# we require very detailed numerical solutions.
line x location= 50.0<nm> spacing= 10.0<nm>                   
line x location= 0.5<um>  spacing= 50.0<nm>                   
line x location= 2.0<um>  spacing= 0.2<um>                      
line x location= 4.0<um>  spacing= 0.4<um>    

# Defining the bottom Si layer                   
line x location= 5.0<um> spacing= 1<um>  tag= SiBottom    

# Defining the left edge of the Si block
line y location= 0.0      spacing= 50.0<nm> tag= Mid  

# Defining the right edge of the Si block
line y location= 0.40<um> spacing=50.0<nm>  tag= Right        


# Initial simulation domain is defined with the region command

region Silicon xlo= SiTop xhi= SiBottom ylo= Mid yhi= Right
init concentration= 1.0e+15<cm-3> field= Phosphorus


###_________________________Boron Implants__________________________###

# First high-energy implantation creates the p-well
implant  Boron  dose= 2.0e13<cm-2>  energy= 200<keV> tilt= 0 rotation= 0  

# Second medium-energy implantation defines a retrograde boron profile to prevent punch-through
implant  Boron  dose= 1.0e13<cm-2>  energy= 80<keV> tilt= 0 rotation= 0  

# Third low-energy implantation is for a threshold voltage (Vt) adjustment.
implant  Boron  dose= 2.0e12<cm-2>  energy= 25<keV> tilt= 0 rotation= 0  


###_________________________Growing Gate Oxide__________________________###

# Gate oxide is grown at 850°C for 10 minutes in pure oxygen ambient using

grid set.min.normal.size= 1<nm> set.normal.growth.ratio.2d= 1.5
diffuse temperature= 1050<C> time= 10.0<s>   
select z=1
layers

###_________________________Defining Polysilicon Gate__________________________###

#  Polysilicon gate is created

## Anisotropic means that the layer is grown only in the vertical direction.
deposit material= {PolySilicon} type= anisotropic time= 1 rate= {0.18}    

# A mask is defined to protect the gate area
mask name= gate_mask left=-1 right= 90<nm>                                

# The etch command (specified as anisotropic) refers to the previously defined mask and, therefore, only the exposed part of the polysilicon is etched
# The requested etching depth (0.2 μm) is larger than the deposited layer, this overetching ensures that no residual islands remain
etch material= {PolySilicon} type= anisotropic time= 1 rate= {0.2} \      
  mask= gate_mask                          

# Second etch statement does not refer to any masks. However, the polysilicon acts naturally as a mask for this selective etching process                               
etch material= {Oxide}       type= anisotropic time= 1 rate= {0.1}        


###_________________________Polysilicon Reoxidation_________________________###

# To release stresses, a thin oxide layer is grown on the polysilicon before spacer formation:

diffuse temperature= 900<C> time= 10.0<min>  O2 

# The edges in the growing oxide, perpendicular to the interface, can be split if their length exceeds a certain value: 

pdbSet Oxide Grid perp.add.dist 1e-7


###_________________________Saving Snapshots__________________________###

struct tdr= n@node@_NMOS1  ; # p-Well

svisual n1_NMOS1_fps.tdr


###_________________________Remeshing for LDD and Halo Implantations__________________________###

refinebox Silicon min= {0.0 0.05} max= {0.1 0.12} xrefine= {0.01 0.01 0.01} \
                                                  yrefine= {0.01 0.01 0.01} add
grid remesh

###_________________________LDD and Halo Implantations__________________________###

#LDD implantation uses a high dose of 4 x 1014 cm-2 and a relatively low energy of 10 keV
implant Arsenic dose= 4e14<cm-2> energy= 10<keV> tilt= 0 rotation= 0  

# Halo is created by a quad implantation, that is, the implantation is performed in four steps, each at a different angle.
implant Boron dose= 0.25e13<cm-2> energy= 20<keV> tilt= 30<degree> \
              rotation= 0            
implant Boron dose= 0.25e13<cm-2> energy= 20<keV> tilt= 30<degree> \
              rotation= 90<degree>   
implant Boron dose= 0.25e13<cm-2> energy= 20<keV> tilt= 30<degree> \
              rotation= 180<degree>  
implant Boron dose= 0.25e13<cm-2> energy= 20<keV> tilt= 30<degree> \
              rotation= 270<degree>  
diffuse temperature= 1050<C> time= 0.1<s> ; # Quick activation 


###_________________________Spacer Formation__________________________###

# First, a uniform, 60-nm thick layer of nitride is deposited over the entire structure
deposit material= {Nitride} type= isotropic  time= 1 rate= {0.06}

# Second, the nitride is etched again. However, now anisotropic etching is used. 
etch    material= {Nitride} type= anisotropic time=1 rate= {0.084} \
				isotropic.overetch= 0.01

# Finally, the thin oxide layer, grown during the poly reoxidation step, is removed.
etch    material= {Oxide}   type= anisotropic time= 1 rate= {0.01} 


###_________________________Remeshing for Source/Drain Implantations__________________________###

# Meshing strategy is updated
refinebox Silicon min= {0.04 0.12} max= {0.18 0.4} xrefine= {0.01 0.01 0.01} \
                                                   yrefine= {0.05 0.05 0.05} add
grid remesh

implant Arsenic dose= 5e15<cm-2> energy= 40<keV> \


###_________________________Source/Drain Implantations__________________________###

implant Arsenic dose= 5e15<cm-2> energy= 40<keV> \
        tilt= 7<degree> rotation= -90<degree>  
diffuse temperature= 1050<C> time= 10.0<s> 


###_________________________Contact Pads__________________________###

deposit material= {Aluminum} type= isotropic time= 1 rate= {0.03}
mask name= contacts_mask left= 0.2<um> right= 1.0<um>
etch material= {Aluminum} type= anisotropic time= 1 rate= {0.25} \
     mask= contacts_mask
#


###_________________________Saving the Full Structure__________________________###

transform reflect left 
struct tdr= n@node@_NMOS ; # Final


###_________________________Extracting 1D Profiles__________________________###

SetPlxList   {BTotal NetActive}
WritePlx n@node@_NMOS_channel.plx  y=0.0 Silicon
SetPlxList   {AsTotal BTotal NetActive}
WritePlx n@node@_NMOS_ldd.plx y=0.1 Silicon
SetPlxList   {AsTotal BTotal NetActive}
WritePlx n@node@_NMOS_sd.plx y=0.39 Silicon


###_________________________Complete__________________________###
