# 🚦 FPGA Traffic Light System  

This project is an **FPGA-based traffic light simulation**, implemented using **VHDL** on a **Xilinx Spartan 3E** FPGA. The system controls traffic lights for a **main road** and a **farm access road**, ensuring safe traffic flow.  

## 📌 Features  
- **Finite State Machine (FSM)** with four states:
  - 🟢 **Main road green, farm red** (`jrhijau_pmerah`)
  - 🟡 **Main road yellow, farm red** (`jrkuning_pmerah`)
  - 🔴 **Main road red, farm green** (`jrmerah_phijau`)
  - 🔴 **Main road red, farm yellow** (`jrmerah_pkuning`)  
- **Push-button control** to trigger traffic light changes.  
- **Configurable delays** for red, yellow, and green lights.  
- **Clock-based timing** to ensure accurate transitions.  

## 📜 How It Works  
1. The system starts with **the main road green and the farm road red**.  
2. Pressing the **push button** moves to the **next state** (main road yellow, farm red).  
3. After a delay, the **main road turns red and the farm road turns green**.  
4. The cycle continues based on preset delays.  
