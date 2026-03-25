# Resource Allocation for Distributed MIMO Radar

This repository contains MATLAB implementations of four typical resource allocation strategies for distributed MIMO radar systems. The code covers two different radar configurations (folders `1` and `2`), each including complete implementations, layout descriptions, and result comparisons for the four strategies.


> **Note**:  
> The implementation of `JAPA` is identical to that of `ABPC`, as `ABPC` does not involve subarray segmentation. For brevity, `JAPA` code is not separately listed; you may refer to the `ABPC` folder. Additionally, the `ABPC` folder includes beamforming simulation programs that can serve as a reference.

##  Description of the Four Allocation Strategies

### 1. Uniform Resource Allocation (URA)  
All radar resources in the distributed network are equally allocated to each UAV target, satisfying all constraints of the optimization model.

### 2. Optimal Power Allocation (OPA)  
The array elements of each radar are first divided into uniform subarrays equal to the number of UAV targets, giving each target the same array gain. Power allocation within each subarray is then optimized to minimize total radiated power while meeting constraints.

### 3. Joint Power Allocation and Beam Selection (JPABS)  
The array elements are divided into a fixed number of uniform subarrays (typically fewer than the number of UAV targets). Appropriate beams are selected from these subarrays to illuminate the targets, and power is optimized to minimize total radiated power under the given constraints.

### 4. Joint Aperture and Power Allocation (JAPA)  
Both the subarray division (aperture) and power allocation are optimized simultaneously to minimize total radiated power while satisfying the constraints.

##  Usage

1. Ensure MATLAB is properly configured.  
2. Navigate to the desired configuration folder (`1` or `2`).  
3. Run the main script for the chosen allocation strategy.  
4. Comparison results can be found in the output data and figures within each subfolder.

##  Notes

- The beamforming examples in the `ABPC` folder are provided for reference regarding subarray and beam design.  
- Detailed constraint definitions and optimization formulations are documented in the code comments.

For further details or questions, please feel free to open an issue.
