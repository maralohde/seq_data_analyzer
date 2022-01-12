include { guppy_gpu } from './process/guppy.nf'

workflow basecalling_wf {
    take: 
        dir_input  
    main:
            guppy_gpu(dir_input)
            guppy_basecalls = guppy_gpu.out.reads
            guppy_summary = guppy_gpu.out.summary
    emit:
        guppy_summary
} 