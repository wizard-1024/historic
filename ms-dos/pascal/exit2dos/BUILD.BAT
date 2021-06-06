IF  "%1" == "sample" GOTO BuildSample

ml /Fl /Fm /Sa /AT /Zf /Zd exit2dos.asm
GOTO Done

:BuildSample
ml /Fl /Fm /Sa /AT /Zf /Zd forever.asm

:Done