-- Rehace el molde en el trabajo abierto: quita los componentes y las trayectorias
-- que tenga y crea un componente por color mas el Desbaste 3D.
-- Copiar a run_lua y ajustar estos valores.
local BLOQUE_X = 144.78        -- ancho del bloque esperado: evita tocar otro trabajo
local ANCHO = 131.513132       -- ancho final del llavero, mm
local X0, Y0 = -72.853353, -68.275057  -- esquina inferior izquierda del llavero
local NX, NY = 1879, 2486      -- tamano del PNG exportado
local CUERPO, COLOR = 3.0, 1.0 -- profundidad del cuerpo y de cada color sobre el cuerpo
local FRESA, DIA = "Fresa plana 1/32 in (0.79 mm)", 0.79375
local PASO_Z, PASO_XY = 0.3, 0.25
local AVANCE, BAJADA, RPM = 600, 150, 18000  -- de prueba: los fija quien mecaniza
local DIR = "C:\\Users\\Sergio reyes\\aspire-mcp\\bridge\\molde\\"

local job = VectricJob()
assert(job.Exists, "no hay trabajo abierto")
assert(math.abs(MaterialBlock().MaterialBox.XLength - BLOQUE_X) < 0.01, "trabajo inesperado")

local lm = job.LayerManager
local quitados = 0
local pos = lm:GetHeadPosition()
while pos ~= nil do
  local layer; layer, pos = lm:GetNext(pos)
  local lista = {}
  local p = layer:GetHeadPosition()
  while p ~= nil do
    local o; o, p = layer:GetNext(p)
    if o.ClassName == "vcCadModelPreview" then table.insert(lista, o) end
  end
  for _, o in ipairs(lista) do layer:RemoveObject(o); quitados = quitados + 1 end
end
print("componentes quitados:", quitados)

local px = ANCHO / NX
local box = Box2D()
box:Merge(Point2D(X0, Y0)); box:Merge(Point2D(X0 + NX * px, Y0 + NY * px))
local comps = {
  {"Negro (cuerpo)", "negro", CUERPO}, {"Blanco", "blanco", COLOR}, {"Verde", "verde", COLOR},
  {"Cafe oscuro", "cafe_oscuro", COLOR}, {"Cafe", "cafe", COLOR},
  {"Terracota", "terracota", COLOR}, {"Naranja", "naranja", COLOR},
}
local cm = job.ComponentManager
for _, c in ipairs(comps) do
  local r = Relief(box, px)
  local w, h = r.PixelWidth, r.PixelHeight
  local f = assert(io.open(DIR .. c[2] .. ".txt", "r"))
  local j, n = 0, 0
  for line in f:lines() do
    if j < h then
      local a = nil
      for num in line:gmatch("%d+") do
        local v = tonumber(num)
        if a == nil then a = v else
          for i = a, math.min(a + v - 1, w - 1) do r:Set(i, j, c[3]); n = n + 1 end
          a = nil
        end
      end
    end
    j = j + 1
  end
  f:close()
  cm:AddRelief(r, CombineMode.Subtract, c[1])
  print(string.format("%s: %dx%d, %d pixeles, %.1f mm", c[1], w, h, n, c[3]))
end
cm:UpdateCompositeModel()

local tpm = ToolpathManager()
tpm:DeleteAllToolpaths()
local t = Tool(FRESA, Tool.END_MILL)
t.InMM = true; t.ToolDia = DIA; t.Stepdown = PASO_Z; t.Stepover = PASO_XY
t.RateUnits = 1; t.FeedRate = AVANCE; t.PlungeRate = BAJADA; t.SpindleSpeed = RPM; t.ToolNumber = 1
local rd = RoughingParameterData()
rd.ZLevelStrategy = RoughingParameterData.RASTER_X
rd.Allowance = 0.0; rd.MachiningAllowance = 0.0
local pp = ToolpathPosData(); pp.SafeZGap = 2.0
job.Selection:Clear()
local ok, id = pcall(function()
  return tpm:CreateRoughingToolpath("Desbaste 3D molde", t, rd, pp, GeometrySelector(), true)
end)
print("Desbaste 3D molde: " .. (ok and (id ~= nil and "creada" or "NO creada") or ("error " .. tostring(id))))
job:Refresh2DView()
