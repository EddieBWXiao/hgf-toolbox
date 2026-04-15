function pstruct = ddm_logrt_pwrbp_namep(pvec)

pstruct = struct; 
pstruct.vscale = pvec(1);
pstruct.bb = pvec(2);
pstruct.z = pvec(3);
pstruct.ndt = pvec(4);
pstruct.v0 = pvec(5);
pstruct.bp = pvec(6);

return;