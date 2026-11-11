import Foundation

/// Textos legales de Fiamas (Terminos y Privacidad).
/// Mantener sincronizados con terms_text.dart y privacy_text.dart de Flutter.
enum LegalText {

    enum Terms {
        static let intro = "Bienvenido a Fiamas. Al descargar, acceder o utilizar nuestra aplicación móvil, aceptas cumplir con los siguientes términos y condiciones. Te recomendamos leerlos con atención."

        static let description = "Fiamas es una herramienta de gestión comercial diseñada para pequeños negocios y bodegas. La aplicación permite:"

        static let features: [String] = [
            "Registrar fiados, productos y control de inventario.",
            "Llevar el registro de fiados, deudas y cobros de clientes.",
            "Visualizar reportes financieros y exportar resúmenes en formato PDF.",
            "Vincular clientes automáticamente con el código QR de tu tienda.",
            "Evaluar el comportamiento de pago de tus clientes con el score de pagador.",
            "Trabajar sin internet con sincronización automática de datos.",
        ]

        static let responsibility = "Responsabilidad de los Datos: Eres responsable de mantener la confidencialidad de tus credenciales de acceso y de toda la actividad que ocurra en tu cuenta."

        static let accuracy = "Exactitud de la Información: Te comprometes a proporcionar información precisa y actualizada al registrar tu negocio y tus productos."

        static let internalUse = "Uso Interno: La información de los clientes (nombres, teléfonos, montos fiados) ingresada en la app es para tu gestión interna."

        static let consent = "Consentimiento: Declaras contar con la autorización de tus clientes para registrar sus datos de contacto y saldos pendientes dentro de la plataforma con fines exclusivamente informativos."

        static let reports = "Los reportes descargados en PDF son para uso informativo y administrativo del usuario."

        static let noInvoice = "Fiamas no emite comprobantes de pago ni facturas electrónicas válidas ante la SUNAT (a menos que integres un sistema de facturación oficial)."

        static let property = "Todo el diseño, código, logotipos, marca y elementos visuales de la aplicación son propiedad exclusiva de Fiamas. Queda prohibida su copia, modificación o distribución sin autorización previa."

        static let balance = "Precisión de Saldos: La app calcula los saldos y reportes en función de los datos que ingreses. No nos hacemos responsables por errores de digitación o pérdida de información por mal uso del dispositivo."

        static let availability = "Disponibilidad: Nos esforzamos por mantener el servicio disponible 24/7, pero no garantizamos un servicio ininterrumpido en caso de mantenimiento o fallas técnicas ajenas a nuestro control."

        static let updates = "Nos reservamos el derecho de actualizar estos Términos y Condiciones en cualquier momento. Notificaremos los cambios relevantes a través de la aplicación o por correo electrónico."

        static let contact = "Si tienes dudas sobre estos términos, puedes escribirnos a través de la sección de Ayuda y Soporte en la app o al correo: soporte@fiamas.com."
    }

    enum Privacy {
        static let intro = "En Fiamas, nos tomamos muy en serio la privacidad y seguridad de tus datos y los de tu negocio. Esta Política de Privacidad describe cómo recopilamos, utilizamos, almacenamos y protegemos tu información personal y comercial cuando utilizas nuestra aplicación móvil."

        static let collectIntro = "Para ofrecerte un funcionamiento óptimo de la aplicación, recopilamos los siguientes datos:"

        static let collectedData: [String] = [
            "Información de la Cuenta y Negocio: Nombre del titular, nombre de la bodega/negocio, dirección física, número de teléfono y correo electrónico.",
            "Información Comercial e Inventario: Nombres de productos, precios, stock, historial de ventas y registros de movimientos financieros.",
            "Información de Clientes y Fiados: Nombres, números de contacto y montos adeudados que ingresas manualmente dentro del módulo de fiados.",
            "Datos Técnicos y de Uso: Dirección IP, tipo de dispositivo, sistema operativo e informes de fallas para mejorar el rendimiento de la app.",
        ]

        static let purposesIntro = "Utilizamos la información recopilada exclusivamente para los siguientes fines:"

        static let purposes: [String] = [
            "Facilitar el control de tus ventas, inventario y gestión de cobranzas a clientes.",
            "Generar los reportes visuales y archivos exportables en formato PDF dentro de la app.",
            "Brindarte soporte técnico y responder a tus consultas en el módulo de ayuda.",
            "Enviar notificaciones importantes sobre actualizaciones de la aplicación o cambios en el servicio.",
        ]

        static let dataSecurity = "Seguridad de los Datos: Protegemos tu información con contraseñas cifradas, conexiones seguras y almacenamiento en servidores cloud de confianza. Solo tú puedes acceder a los datos de tu negocio con tu sesión activa."

        static let retention = "Conservación de la Información: Conservamos tus datos mientras tu cuenta esté activa. Si decides eliminar tu cuenta, toda la información asociada será borrada de forma definitiva de nuestros servidores."

        static let thirdPartiesIntro = "No compartimos tus datos personales ni comerciales con terceros, salvo en las siguientes excepciones:"

        static let thirdParties: [String] = [
            "Proveedores de Servicios Cloud: Para el alojamiento seguro de la base de datos de tu app.",
            "Requerimiento Legal: Cuando sea exigido por ley o por orden de una autoridad competente.",
        ]

        static let rights = "Tienes derecho a acceder, rectificar, actualizar o solicitar la eliminación definitiva de tu cuenta y todos los datos registrados en la app. Puedes ejercer estos derechos enviando una solicitud desde la sección de Configuración / Perfil o escribiéndonos a jhad@fiamas.com."

        static let updates = "Nos reservamos el derecho de actualizar esta Política de Privacidad en cualquier momento. Notificaremos cualquier cambio significativo publicando la nueva versión dentro de la app con la fecha actualizada."

        static let contactIntro = "Si tienes preguntas o dudas sobre esta Política de Privacidad, puedes contactarnos directamente en:"

        static let contactChannels: [String] = [
            "Correo de soporte: soporte@fiamas.com",
            "Sección de Soporte: Menú Ayuda dentro de la App.",
        ]
    }
}
