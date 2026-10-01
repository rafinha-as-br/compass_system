package com.compass.compass_system.notification;

import org.springframework.amqp.core.Binding;
import org.springframework.amqp.core.BindingBuilder;
import org.springframework.amqp.core.DirectExchange;
import org.springframework.amqp.core.Queue;
import org.springframework.amqp.support.converter.Jackson2JsonMessageConverter;
import org.springframework.amqp.support.converter.MessageConverter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

// Declares the queue/exchange/binding for notification events, and a JSON
// message converter — Spring Boot auto-configures RabbitTemplate and the
// @RabbitListener container factory to use whichever MessageConverter bean
// is present, so nothing else needs wiring by hand.
@Configuration
public class RabbitMQConfig {

    public static final String QUEUE = "notifications.queue";
    public static final String EXCHANGE = "notifications.exchange";
    public static final String ROUTING_KEY = "notifications.created";

    @Bean
    public Queue notificationQueue() {
        return new Queue(QUEUE, true);
    }

    @Bean
    public DirectExchange notificationExchange() {
        return new DirectExchange(EXCHANGE);
    }

    @Bean
    public Binding notificationBinding() {
        return BindingBuilder.bind(notificationQueue()).to(notificationExchange()).with(ROUTING_KEY);
    }

    @Bean
    public MessageConverter jsonMessageConverter() {
        return new Jackson2JsonMessageConverter();
    }
}
