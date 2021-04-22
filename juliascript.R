#opening and running circuitscape.jl

library(ResistanceGA)

'''sp.dat <- sample_pops$sample_cont
cont.rast <- raster_orig$cont_orig
gen.dist <- Dc_list$Dc_cont

plot(cont.rast)
plot(sp.dat, add = T,   pch = 19 )''' #sample functionality

JULIA_HOME <- "C:/Users/merri/AppData/Local/Programs/Julia-1.6.0/bin"
JuliaCall::julia_setup(JULIA_HOME)

GA.inputs <- GA.prep(ASCII.dir = cont.rast,Results.dir = "C:/Rga_examples/",parallel = 4)
#this doesn't work. was Rga_examples supposed to be downloaded at some ponit? 
jl.inputs <- jl.prep(n.Pops =length(sp.dat),response =lower(gen.dist),CS_Point.File = sp.dat,JULIA_HOME = JULIA_HOME)

jl.optim <- SS_optim(jl.inputs = jl.inputs)
#requires GA.inputs
