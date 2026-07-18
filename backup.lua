    -- Logik beim Zuklappen des Laptops
    hl.bind("switch:on:Lid Switch", function()
        -- Liste aller aktuell verbundenen und aktiven Monitore abrufen
        local monitors = hl.get_monitors()

        -- Überprüfen, ob mehr als der interne Monitor (eDP-1) existiert
        if #monitors > 1 then
            -- Externer Monitor ist angeschlossen -> Clamshell Mode
            -- Interner Bildschirm eDP-1 wird deaktiviert, das System läuft auf dem externen weiter
            hl.exec_cmd("hyprctl keyword monitor 'eDP-1, disable'")
        else
            -- Kein externer Monitor angeschlossen -> Mobiler Betrieb
            -- System sperren
            hl.exec_cmd("hyprlock")

            -- Optional: Wenn du willst, dass er beim Sperren auch in den Standby (Suspend) geht,
            -- entferne die Kommentierung in der nächsten Zeile:
            -- hl.exec_cmd("systemctl suspend")
        end
    end, { locked = true })


    -- Logik beim Aufklappen des Laptops
    hl.bind("switch:off:Lid Switch", function()
        -- Den internen Monitor auf jeden Fall wieder aktivieren
        -- (Der Parameter 'locked = true' beim Bind ist wichtig, damit das auch auf dem Lockscreen klappt)
        hl.exec_cmd("hyprctl keyword monitor 'eDP-1, preferred, auto, 1'")
    end, { locked = true })
end
