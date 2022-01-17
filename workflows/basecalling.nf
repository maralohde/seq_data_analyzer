include { guppy_gpu } from './process/guppy.nf'
include { flye } from './process/flye.nf'

workflow basecalling_wf {
    take: 
        fast5_input
    main:
            guppy_gpu(fast5_input)
            guppy_basecalls = guppy_gpu.out.reads
            guppy_summary = guppy_gpu.out.summary
            flye(guppy_gpu.out.reads)
} 