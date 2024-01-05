# hust-cse-crypto-verilog

**华中科技大学网络空间安全学院密码工程学基础2023**

*powered by mxy*

------

*First，用过本课程库的请star一下~*

请首先`git clone https://github.com/mapkkkk/hust-cse-crypto-verilog.git`

四个实验分别在四个文件夹里，请使用iverilog编译，先编译代码本体如`aes.v`，再编译`test bench`如`tb_aes.v`。运行完`testbench`(`terminal`输出**[done]**)之后，在工程目录下将会产生wave.vcd文件，此即仿真波形，打开后添加想观察的内容即可。

编译工具链推荐使用`vscode`+`iverilog`，具体安装方法请自行搜索(知乎上有)。需要烧录在**FPGA**板子上的，请使用`vivado`生成比特流（课程第一节课会讲），同时，仿真占比90%，纯仿真使用`vscode`即可。

实验2、3、4我上传了我的仿真波形(`wave.vcd`)，在`vscode`中可以通过`WaveTrace`打开查看，仅供参考。各个实验的核心文件如下：**实验1:**`Computation.v`;**实验2:**`aes.v`;**实验3:**`sha_engine.v`;**实验4:**`mont_mult_modif.v`

最后，附上我的报告**仅供参考**(**report.pdf**)。

*仅供参考，请不要抄袭，学院有查重系统。*

------

我的库部分内容远大于课程需求，不需要理会，具体如下：

- **AES**实验只需要行移位，不需要**S盒代换**和**列混合**
- 蒙哥马利模乘**只需要最后一步**
