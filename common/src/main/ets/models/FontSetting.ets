/**
 * 字号设置数据类：@Trace 字段变化 → 所有 connect 页面刷新 + 自动写盘
 * fontSize 为"偏移量"：0 标准；实际字号 = 各处基准字号 + fontSize
 */
@ObservedV2
export class FontSetting {
  @Trace fontSize: number = 0
}

/** 字号档位描述 */
export interface FontLevel {
  label: string
  size: number
}

/** 5 档字号定义（单一数据源：改这里即全局生效） */
export const FONT_LEVELS: FontLevel[] = [
  { label: '极小', size: -4 },
  { label: '小',   size: -2 },
  { label: '标准', size:  0 },
  { label: '大',   size:  2 },
  { label: '极大', size:  4 }
]