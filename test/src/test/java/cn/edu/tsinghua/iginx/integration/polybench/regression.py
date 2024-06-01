def process_time_costs(file_path):
    old = []
    new = []

    with open(file_path, 'r') as file:
        lines = file.readlines()

    for i in range(0, len(lines), 5):
        # 读取每五行
        batch = lines[i:i+5]
        if len(batch) < 5:
            break

        # 提取时间值并去掉' ms'
        times = [int(line.split(':')[1].strip().split()[0]) for line in batch]

        # 前两行取平均值存入old数组
        old_avg = sum(times[:3]) / 3
        old.append(old_avg)

        # 后三行取平均值存入new数组
        new_avg = sum(times[3:]) / 2
        new.append(new_avg)

    return old, new

# 使用方法
file_path = 'output.txt'
old, new = process_time_costs(file_path)
print("Old array:", old)
print("New array:", new)
task = ["Cleaning", "SGD", "PageRank"]

# 输出
for i in range(len(old)):
    print(f"Task: {task[i]},\t\t Old: {old[i]} ms,\t\t New: {new[i]} ms.")
    if old[i] - new[i] > old[i] * 0.3:
        print("Regression detected!")
