#!/usr/bin/env python

# CI-optimized SCons configuration for fast builds
# This file provides optimized defaults for GitHub CI builds

import os
import multiprocessing

def options(opts, env):
    """Add CI-optimized options to SCons."""
    
    # Detect if running in CI environment
    is_ci = any(key in os.environ for key in ['CI', 'GITHUB_ACTIONS', 'CONTINUOUS_INTEGRATION'])
    
    if is_ci:
        # CI-specific optimizations
        cpu_count = multiprocessing.cpu_count()
        opts.Add("num_jobs", "Number of parallel jobs", cpu_count)
        opts.Add("verbose", "Verbose output", False)
        opts.Add("progress", "Show build progress", False)
        opts.Add("warnings", "Warning level", "default")
        
        # Memory usage optimizations for CI
        opts.Add("debug_symbols", "Debug symbols in build", False)
    else:
        # Local development defaults - minimal configuration
        opts.Add("num_jobs", "Number of parallel jobs", min(8, multiprocessing.cpu_count()))

def configure(env):
    """Configure environment for CI or local builds."""
    
    # Detect if running in CI environment
    is_ci = any(key in os.environ for key in ['CI', 'GITHUB_ACTIONS', 'CONTINUOUS_INTEGRATION'])
    
    if is_ci:
        print("🚀 CI build detected - optimizing for speed and parallelism")
        
        # Set maximum parallelism
        cpu_count = multiprocessing.cpu_count()
        env.SetOption('num_jobs', cpu_count)
        
        # Suppress verbose output in CI for cleaner logs
        env['verbose'] = False
        env['progress'] = False
        
        # Optimize for build speed
        if env.get('target') == 'template_release':
            env.Append(CPPFLAGS=['-O3'])  # Maximum optimization
            env['debug_symbols'] = False  # Reduce binary size
            
        print(f"Using {cpu_count} parallel jobs for CI build")
    else:
        # Local development - provide reasonable defaults
        local_jobs = min(8, multiprocessing.cpu_count())
        print(f"Local build detected - using {local_jobs} parallel jobs")
