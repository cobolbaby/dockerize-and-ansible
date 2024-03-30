import numpy as np

def create_and_fill_array(rows, cols):
    # 创建一个二维数组，初始值为0
    arr = np.zeros((rows, cols), dtype=int)

    # 为每个元素赋值
    for i in range(rows):
        for j in range(cols):
            arr[j][i] = i * cols + j  # 或者使用其他你想要的赋值逻辑

    return arr

# 定义数组的大小
rows = 10240
cols = 10240

# 创建并填充数组
my_array = create_and_fill_array(rows, cols)

# 打印数组的一部分，仅作为示例
print("Array slice:")
print(my_array[:3, :3])
