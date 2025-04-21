import glob
import os
from datetime import datetime

import pyarrow as pa
import pyarrow.compute as pc
import pyarrow.parquet as pq
import pytz
from dotenv import load_dotenv

load_dotenv()

LOCAL_TIMEZONE = pytz.timezone(os.getenv("TIMEZONE", "Asia/Shanghai"))

def parse_tsms(ts_value):
    if isinstance(ts_value, str):
        return LOCAL_TIMEZONE.localize(datetime.strptime(ts_value, "%Y-%m-%d %H:%M:%S"))
    elif isinstance(ts_value, datetime):
        if ts_value.tzinfo is None:
            return LOCAL_TIMEZONE.localize(ts_value)
        return ts_value.astimezone(LOCAL_TIMEZONE)
    else:
        raise ValueError(f"不支持的 tsms 格式: {ts_value}")

def convert_tsms(input_file, output_file):
    try:
        # 读取 Parquet 文件
        table = pq.read_table(input_file)
        
        tsms_column = table['tsms']

        # 将 tsms 字段转换为带时区的时间
        tsms_converted = [parse_tsms(tsms_str) for tsms_str in tsms_column.to_pylist()]

        # 将转换后的时间戳列转换为 pyarrow timestamp 类型
        tsms_timestamp = pa.array(tsms_converted, type=pa.timestamp('ms'))

        # 替换原始的 tsms 列为新的转换后的列
        new_table = table.set_column(table.schema.get_field_index('tsms'), 'tsms', tsms_timestamp)
        
        # 保存修改后的 Parquet 文件到输出目录
        pq.write_table(new_table, output_file)
        print(f"成功转换并保存：{input_file} -> {output_file}")

    except Exception as e:
        print(f"处理文件 {input_file} 时发生错误: {e}")

def main():
    # 定义输入目录和输出目录
    input_directory = './cache/BDC/IMX_PG/bdc/dw/fact_cpu_sno_parts/cdc/'
    output_directory = './cache/BDC/IMX_PG/bdc/dw/fact_cpu_sno_parts/cdc2/'

    # 获取所有 Parquet 文件的路径
    parquet_files = glob.glob(os.path.join(input_directory, '**', '*.parquet'), recursive=True)
    
    # 遍历每个 Parquet 文件，进行转换
    for input_file in parquet_files:
        # 生成输出文件的路径
        output_file = os.path.join(output_directory, os.path.relpath(input_file, input_directory))
        os.makedirs(os.path.dirname(output_file), exist_ok=True)
        
        # 转换并保存
        convert_tsms(input_file, output_file)

if __name__ == '__main__':
    main()
