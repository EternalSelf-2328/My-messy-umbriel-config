// Función de ruido pseudoaleatorio estándar
float gh(float n) {
    return fract(sin(n) * 43758.5453);
}

vec4 animation(vec2 uv) {
    // Progresión de la animación (0.0 a 1.0)
    float p = umbriel_clamped_progress;

    // Queremos que el glitch sea más intenso en el medio de la transición
    // y nulo al inicio (0.0) y al final (1.0)
    float intensity = sin(p * 3.14159);
    
    // Intensificamos el efecto para que el pico sea más abrupto
    intensity = intensity * intensity;

    // Usamos umbriel_random_seed.x como base para evitar repeticiones visuales 
    // exactas en cada cambio de workspace
    float tick = floor(p * 60.0) + umbriel_random_seed.x * 1000.0;

    // Cálculo de desplazamientos RGB
    float r1 = gh(tick * 1.13);
    float r2 = gh(tick * 2.37);
    float r3 = gh(tick * 3.71);
    float r4 = gh(tick * 4.19);
    float r5 = gh(tick * 5.53);
    float r6 = gh(tick * 6.91);

    // Los multiplicadores (.15) controlan qué tan fuerte se separan los colores
    vec2 off_r = vec2(r1 - 0.5, r2 - 0.5) * intensity * 0.15;
    vec2 off_g = vec2(r3 - 0.5, r4 - 0.5) * intensity * 0.15;
    vec2 off_b = vec2(r5 - 0.5, r6 - 0.5) * intensity * 0.15;

    // Slicing (desgarro horizontal) dividiendo la pantalla en 20 franjas
    float slice = floor(uv.y * 20.0);
    float slice_offset = (gh(slice + tick) - 0.5) * intensity * 0.12;

    vec2 uv_r = uv + off_r + vec2(slice_offset * 0.7, 0.0);
    vec2 uv_g = uv + off_g + vec2(slice_offset * -0.5, 0.0);
    vec2 uv_b = uv + off_b + vec2(slice_offset * 0.3, 0.0);

    // Muestreo individual por canal de color usando la API de Umbriel
    vec4 col_r = umbriel_sample(uv_r);
    vec4 col_g = umbriel_sample(uv_g);
    vec4 col_b = umbriel_sample(uv_b);

    vec4 color;
    color.r = col_r.r;
    color.g = col_g.g;
    color.b = col_b.b;
    // Preservamos el canal alfa original para evitar problemas con bordes oscuros
    color.a = max(max(col_r.a, col_g.a), col_b.a);

    // Glitch aleatorio que desplaza un bloque de la pantalla
    float big_glitch = step(0.7, gh(tick * 0.77));
    vec2 shift = vec2((gh(tick * 1.5) - 0.5) * 0.08 * big_glitch * intensity, 0.0);
    vec4 shifted = umbriel_sample(uv + shift);
    color = mix(color, shifted, big_glitch * intensity * 0.5);

    // Efecto Scanline (líneas tipo monitor CRT)
    float scanline = 1.0 - sin(uv.y * umbriel_size.y * 3.14159) * 0.08 * intensity;
    color.rgb *= scanline;

    return color;
}
