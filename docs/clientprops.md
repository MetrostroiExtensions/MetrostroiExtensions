# Работа с клиентскими пропами
ClientProps - это клиентская таблица, описывающая все клиентские энтити, которые необходимо создать и прицепить к вагону

## Описание таблицы ClientProps
* `model` - путь до модели клиентпропа
* `[modelcallback]` - callback, который позволяет динамически менять модель. Получает энтити самого вагона. Должен вернуть путь до модели. Если этот callback возвращает `nil`, то будет использована модель по умолчанию (тоесть модель, указанная в `model`)
* `pos` - положение клиентпропа относительно координат вагона
* `ang` - угол поворота клиентпропа относительно вагона
* `[callback]` - callback, который получает энтити вагона и энтити только что созданного клиентпропа.
* `[skin]` - скин клиентпропа (по умолчанию равен нулю)
* `[scale]` - масштаб клиентпропа
* `[bscale]` - масштаб кости с id=0. Подробнее можно узнать из метода `Entity:ManipulateBoneScale`
* `[bodygroup]` - таблица бадигруп, где ключ - это id бадигруппы, а значение - значение для этой бадигруппы
* `[color]` - цвет клиентпропа
* `[colora]` - цвет клиентпропа с альфа-каналом. Имеет больший приоритет, чем простой `color`
* `[nohide]` - флаг, говорящий о том, что данный клиентпроп нельзя скрывать
* `[hide]` - если данное значение задано, то оно будет использованно как коэффицент для дальности прорисовки.
* `[hideseat]` - если данное значение задано, то оно будет использованно как коэффицент для дальности прорисовки, но только если игрок сидит в сиденье, не принадлежащем данному вагону

## Автопрекэш моделей
Для ускорения прогрузки новых моделей используется механизм прекэширования моделей. Данный механизм необходим для того, чтобы движок игры загружал модель не при спавне состава (или при первом появлении модели в составе - допустим, если модель горящей лампочки изначально скрыта, то движок подгрузит её только тогда, когда она загориться)

Metrostroi Extensions старается автоматически прекэшировать все модели, о которых он знает.

### MEL.AddToModelPrecacheTable - добавить модель в список для прекэширования
`MEL.AddToModelPrecacheTable(model)` - добавляет модель в список для прекэширования

* `model` - путь к модели, которую надо прекэшировать

*(scope: Client)*

**Пример использования**:
```lua
MEL.AddToModelPrecacheTable("models/some_model.mdl")
```

## Автоперезагрузка пропов
MetrostroiExtensionsLib умеет автоматически пересоздавать пересоздавать клиентпропы при обновлении какой-либо сетевой переменной.

Для этого клиентпроп необходимо пометить как "требующий пересоздания" функцией [MEL.MarkClientPropForReload](clientprops.md#melmarkclientpropforreload-)

Также, почти в каждой фукнции, которая изменяет ClientProp, можно сразу передать название сетевой переменной - тогда данная функция пометит данный клиентпроп для автоперезагрузки за вас.

### MEL.MarkClientPropForReload - пометить клиентпроп для автоперезагрузки
/// admonition
    type: tip

Данную функцию стоит использовать для обновления пропа при изменении поля в спавнере.
///

`MEL.MarkClientPropForReload(ent_or_entclass, clientprop_name_or_names, field_name_or_names)` - помечает данный клиентпроп как требующей перезагрузки при изменении одной или нескольких сетевых переменных.

*(scope: Client)*

* `ent_or_entclass` - имя энтити или сама энтити
* `clientprop_name` - имя клиентпропа или таблица с именами клиентпропов
* `field_name_or_names` - имя поля или таблица с именами полей 

**Пример использования**:
```lua
-- одна переменная
MEL.MarkClientPropForReload(ent, "some_clientprop", "SomeVar")
-- несколько переменных
MEL.MarkClientPropForReload("gmod_subway_81-775", "other_clientprop", {"SomeVar1", "SomeVar2"})
```

## Изменение существующих пропов
### MEL.DeleteClientProp - удалить клиентпроп

`MEL.DeleteClientProp(ent, clientprop_name, error_on_nil)` - удаляет клиентпроп

*(scope: Client)*

* `ent` - энтити вагона
* `clientprop_name` - имя клиентпропа
* `[error_on_nil]` - вызывать ли ошибку если такого клиентпропа нет (по умолчанию - не вызывать)

**Пример использования**:
```lua
MEL.DeleteClientprop(ent, "some_clientprop")
```

### MEL.UpdateModelCallback - замена ModelCallback
/// admonition
    type: tip

Данную функцию стоит использовать для замены модели уже существующего клиентпропа.
///

`MEL.UpdateModelCallback(ent, clientprop_name, new_modelcallback, [field_name], [error_on_nil], [do_not_precache])` - Обновляет `modelcallback` существующего клиентпропа.

*(scope: Client)*

* `ent` - энтити вагона
* `clientprop_name` - имя клиентпропа
* `new_modelcallback` - новая функция modelcallback ИЛИ новый путь к модели
* `[field_name]` - имя поля или полей для [автоперезагрузки пропов](clientprops.md#_3)
* `[error_on_nil]` - вызывать ли ошибку если такого клиентпропа нет (по умолчанию - не вызывать)
* `[do_not_precache]` - не прекэшировать модель. См. [Автопрекэш моделей](clientprops.md#_2)

Прекэш моделей работает только тогда, когда new_modelcallback - строка с новым путем к модели.

**Пример использования**:
```lua
-- просто заменить модель:
MEL.UpdateModelCallback(ent, "some_clientprop", "models/new_model.mdl")
-- заменить модель с какой-то логикой:
MEL.UpdateModelCallback(ent, "some_clientprop", function(ent)
    if ent:GetNW2Bool("SomeClientpropOldModel") then
        return "models/old_model.mdl"
    end
    return "models/new_model.mdl"
end, "SomeClientpropOldModel") -- помечаем проп для авторелоуда при изменении сетевой переменной SomeClientpropOldModel
```

### MEL.UpdateCallback - замена Callback
/// admonition
    type: tip

Данную функцию стоит использовать для перемещения пропа или любых других действий с ним
///

`MEL.UpdateCallback(ent, clientprop_name, new_callback, [field_name], [error_on_nil])` - Обновляет `callback` существующего клиентпропа.

*(scope: Client)*

* `ent` - энтити вагона
* `clientprop_name` - имя клиентпропа
* `new_callback` - новая функция callback
* `[field_name]` - имя поля или полей для [автоперезагрузки пропов](clientprops.md#_3)
* `[error_on_nil]` - вызывать ли ошибку если такого клиентпропа нет (по умолчанию - не вызывать)

**Пример использования**:
```lua
-- передвинуть модель в нули
MEL.UpdateCallback(ent, "some_clientprop", function(ent, cent)
    cent:SetLocalPos(zero_vector)
end)
-- красим модель в красный, если сетевая переменная равна true
MEL.UpdateCallback(ent, "other_clientprop", function(ent, cent)
    if ent:GetNW2Bool("IsOtherClientpropRed") then
        cent:SetColor(Color(255, 0, 0))
    end
end, "IsOtherClientpropRed") -- помечаем проп для авторелоуда при изменении сетевой переменной IsOtherClientpropRed
```

### MEL.OverrideShowHide - перезаписать логику ShowHide для пропа
/// admonition
    type: tip

Данную функцию стоит использовать, если вам необходимо изменить поведение ранее вызванной функции ShowHide (допустим, если она вызывается в стандартном Think метростроя)
///
`MEL.OverrideShowHide(ent, clientprop_name, value_callback)` - позволяет изменить логику для фукнции ShowHide, которую уже вызывали до этого в коде для этого пропа

*(scope: Client)*

* `ent` - энтити вагона
* `clientprop_name` - имя клиентпропа
* `value_callback` - функция, принимающая энтити вагона, которая должна возврашать true или false в зависимости от того, необходимо ли скрывать данный клиентпроп

**Пример использования**:
```lua
-- не даем стандартному коду метростроя скрывать 013 кран,
-- если сетевая переменная Always013 - true
MEL.OverrideShowHide(ent, "brake013", function(ent)
    if ent:GetNW2Bool("Always013") then
        return true
    else
        return false
    end
end)
```

### MEL.OverrideAnimate - перезаписать параметры анимации пропа
/// admonition
    type: tip

Данную функцию стоит использовать, если вам необходимо изменить параметры анимации, такие как max, min, speed, damping, stickyness.
Полезно, если вы изменили модель пропа на свою со своей анимацией.
///
`MEL.OverrideAnimate(ent, clientprop_name, min_or_callback, max, speed, damping, stickyness)` - перезаписать параметры анимации пропа

*(scope: Client)*

* `ent` - энтити вагона
* `clientprop_name` - имя клиентпропа
* `min_or_callback` - новое значение min для функции Animate ИЛИ функция, которая принимает энтити вагона, а возвращает таблицу с пятью параметрами
* `max` - новое значение max для функции Animate
* `speed` - новое значение speed для функции Animate
* `[damping]` - новое значение damping для функции Animate
* `[stickyness]` - новое значение stickyness для функции Animate

**Пример использования**:
```lua
-- меняем начало и конец анимации у 013
-- стандартные значения - 0.03, 0.458, 256, 24
MEL.OverrideAnimate(ent, "brake013", 0, 1, 256, 24)


-- меняем начало и конец анимации у 334 в зависимости от сетевой переменной
-- стандартные значения - 0.35, 0.65, 256, 24
MEL.OverrideAnimate(ent, "brake334", function(wagon)
    if ent:GetNW2Bool("SomeVar") then
        return {0, 1, 256, 24, nil}
    end
    return {0.35, 0.65, 256, 24, nil}
end)
```

### MEL.OverrideAnimateValue - перезаписать состояние анимации пропа
/// admonition
    type: tip

Данную функцию стоит использовать, если вам необходимо состояние анимации пропа (value в Animate).
К примеру, вы хотите изменить стандартную логику анимации какой-то существующей модели
///
`MEL.OverrideAnimateValue(ent, clientprop_name, value_callback)` - перезаписать стандартную логику анимации существующей модели

*(scope: Client)*

* `ent` - энтити вагона
* `clientprop_name` - имя клиентпропа
* `value_callback` - функция, которая принимает энтити вагона, а возвращает текущее значение для анимации

**Пример использования**:
```lua
-- делаем так, что 013 - всегда в крайнем положении.
MEL.OverrideAnimateValue(ent, "brake013", function(ent)
    return 1
end)

-- делаем так, что 334 - всегда в другом крайнем положении, если сетевая переменная - true
-- иначе стандартная логика
MEL.OverrideAnimateValue(ent, "brake334", function(ent)
    if ent:GetNW2Bool("SomeVar") then
        return 0
    end
    return ent:GetPackedRatio("CranePosition") / 5
end)
```

## Добавление нового клиентского пропа
### MEL.NewClientProp - добавить новый клиентский проп

`MEL.NewClientProp(ent, clientprop_name, clientprop_info, field_name, do_not_override, do_not_precache)` - добавить новый клиентский проп

*(scope: Client)*

* `ent` - энтити вагона
* `clientprop_name` - имя клиентпропа
* `clientprop_info` - описание клиентпропа (см. [описание таблицы ClientProps](clientprops.md#clientprops))
* `[field_name]` - имя поля или полей для [автоперезагрузки пропов](clientprops.md#_3)
* `[do_not_override]` - вызывать ли ошибку если такой клиентпроп уже есть (по умолчанию - не вызывать)
* `[do_not_precache]` - не прекэшировать модель. См. [Автопрекэш моделей](clientprops.md#_2)

**Пример использования**:
```lua
-- пример из стандартного рецепта для кастомизации ламп
MEL.NewClientProp(ent, "salon_lamps_base", {
    model = MODELS_ROOT .. "lamps_type1.mdl",
    pos = vector_origin,
    ang = angle_zero,
    hide = 1.5,
    modelcallback = function(wagon) return getLampData(wagon).model end,
    callback = function(wagon, cent)
        local lamp_data = getLampData(wagon)
        if lamp_data.callback then lamp_data.callback(wagon, cent) end
    end
}, "SalonLampType")
```

## Вспомогательные функции
### MEL.CachedDecorator - декоратор для кэширования
/// admonition
    type: tip

Данную функцию стоит использовать, если вы самостоятельно передвигаете кости для создания анимаций.
При таких анимация необходимо каждый кадр создавать новый Vector - это дорогая операция.
///
`MEL.CachedDecorator(ent_or_entclass, decorator_name, getter, precision)` - возвращает новый декоратор для кэширования значений функции

*(scope: Client)*

* `ent_or_entclass` - энтити вагона или его класс
* `clientprop_name` - имя клиентпропа
* `decorator_name` - имя для декоратора
* `getter` - функция для получения значения
* `[precision]` - точность округления


**Пример использования**:
```lua
-- кэшируем угол поворота для педали
local getPBAngle = MEL.CachedDecorator(ent, "PB", function(value) return Angle(0, 0, value * 5 * -30) end)

-- в коде используем как-то так:
getPBAngle(wagon.Anims["PB"].value)
```
