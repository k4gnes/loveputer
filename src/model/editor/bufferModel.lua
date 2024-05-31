require('util.table')

--- @alias Content Dequeue
--- @alias Selected integer[]

--- @class BufferModel
--- @field name string
--- @field content Content
--- @field selection Selected
---
--- @field move_highlight function
BufferModel = {}
BufferModel.__index = BufferModel

setmetatable(BufferModel, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

--- @param name string
--- @param content string[]?
function BufferModel.new(name, content)
  local buffer = Dequeue(content)
  buffer:push_back('EOF')
  local self = setmetatable({
    name = name or 'untitled',
    content = buffer,
    selection = { #buffer },
  }, BufferModel)

  return self
end

--- @return string[]
function BufferModel:get_content()
  return self.content or {}
end

--- @return integer
function BufferModel:get_content_length()
  return #(self.content) or 0
end

--- @param dir VerticalDir
--- @return boolean moved
function BufferModel:move_highlight(dir)
  -- TODO chunk selection
  local cur = self.selection[1]
  if dir == 'up' then
    if cur > 1 then
      self.selection[1] = cur - 1
      return true
    end
  end
  if dir == 'down' then
    if cur < #(self.content) then
      self.selection[1] = cur + 1
      return true
    end
  end
  return false
end

--- @return Selected
function BufferModel:get_selection()
  return self.selection
end

--- @return string[]
function BufferModel:get_selected_text()
  local sel = self.selection
  -- continuous selection assumed
  local si = sel[1]
  local ei = sel[#sel]
  if ei == #(self.content) then ei = ei - 1 end
  return table.slice(self.content, si, ei)
end

function BufferModel:delete_selected_text()
  local sel = self.selection
  -- continuous selection assumed
  for i = #sel, 1, -1 do
    self.content:remove(sel[i])
  end
end

--- @param t string[]
function BufferModel:replace_selected_text(t)
  local sel = self.selection
  if #sel == 1 then
    if #t == 1 then
      self.content[sel[1]] = t[1]
    end
  else
    -- TODO multiine
  end
  -- -- continuous selection assumed
  -- for i = #sel, 1, -1 do
  --   self.content:remove(sel[i])
  -- end
end
