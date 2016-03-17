Python Coding Style
=====================


### 缩进
因为python是通过缩进来区分代码逻辑的，所以首先是代码缩进问题，一贯原则是不要使用Tab(tab和空格混在一起最恶心了有木有>_<...), 可以把Tab替换成4个空格，参考我的vim设置

```
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
```

### import顺序
```
先按字母顺序import python标准库
空行\n
按字母顺序导入第三方库
空行\n
按字母顺序导入自已写的库
空行\n
空行\n
你的代码

e.g.
import os
import sys
reload(sys)
sys.setdefaultencoding('utf-8')

import json
import requests
import urllib

from myproject import hello, world
```

### 函数注释docstring
```
e.g.

def func(foo, bar):
    """A multi line docstring has a one-line summary, less than 80 characters.
    
    Then a new paragraph after a newline that explains in more detail any general
    information about the function, class or method.
    
    :param foo: the foo parameter
    :param bar: the bar parameter
    :returns: return_type -- description of the return value
    :returns: description of the return value
    :raises: AttributeError, KeyError
    """

    return value
```

### 字典和列表缩进
```
e.g.

list_of_strings = [
    'what_a_long_string',
    'not as long',
]

dict_of_numbers = {
    'one': 1,
    'two': 2,
    'twenty four': 24,
}
```

### 函数调用时参数缩进
```
e.g.

object_one.call_a_method('string three', 'string four',
                         kwarg1=list_of_strings,
                         kwarg2=dict_of_numbers)
```

### 空行
- top-level函数与类之间用两个空行隔开
- 类方法之间用一个空行隔开
```
e.g.

def hello():
    pass


def world():
    pass


class A(object):

    attr = 'attr'

    def ahello(self):
        pass

    def aworld(self):
        pass
```

### 命名
- 变量, 函数, 类命名不要与内置函数或关键字重合
- 常量大写

### 空格
- 各种右括号前不要加空格
- 逗号, 冒号, 分号前不要加空格
- 函数的左括号前不要加空格, e.g. Func(1)
- 序列的左括号前不要加空格, e.g. list[2]
- 函数默认参数使用的赋值符左右省略空格
```
e.g.

def func(a, b=None, c=None):
    pass
```
- 不要将多句语句写在同一行, 尽管使用';'允许
- if/for语句中, 即使执行语句只有一句, 也必须另起一行

### 参考
[PEP8](https://www.python.org/dev/peps/pep-0008/)
[OpenStack社区代码规范](http://docs.openstack.org/developer/hacking/)
