function pstruct = ddm_logrt_minimal_namep(pvec)

pstruct = struct;
pstruct.vscale = pvec(1); 
pstruct.a = pvec(2);
pstruct.z = pvec(3);
pstruct.ndt = pvec(4);
pstruct.v0 = pvec(5);

return;